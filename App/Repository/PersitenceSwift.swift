//
//  PersitenceSwift.swift
//  PokeDb
//
//  Created by Yan  on 27/12/2025.
//
import Foundation
import SwiftData
import UIKit

struct PersistenceSwiftController{
    let container:ModelContainer
    static let shared:PersistenceSwiftController = {
        do{
            return try PersistenceSwiftController(container: ModelContainer(for: PokeItem.self))
        }catch {
            fatalError("Resolving shared SwiftData for container critical error: \(error)")
        }
    }()
    
    @MainActor
    static let preview:PersistenceSwiftController = {
        do{
            let schema = Schema([PokeItem.self])
            let configuration = ModelConfiguration(schema: schema,isStoredInMemoryOnly: true)
            let controller = try PersistenceSwiftController(container: ModelContainer(for: schema, configurations: [configuration]))
            
            let viewContext = controller.container.mainContext
            let newItem = PokeItem()
            newItem.id = 1
            newItem.name = "bulbasaur"
            newItem.types = ["grass","poison"]
            newItem.hp = 45
            newItem.attack = 49
            newItem.defence = 49
            newItem.specialAttack = 65
            newItem.specialDefense = 65
            newItem.speed = 45
            newItem.spriteURL = URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png")
            newItem.shinyURL = URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/shiny/1.png")
            viewContext.insert(newItem)
            
            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
            return controller
        }catch {
            fatalError("Resolving preview SwiftData container critical error: \(error)")
        }
    }()
    @MainActor
    func fetchItemForPreveiw() -> PokeItem{
        do{
            var descriptor = FetchDescriptor<PokeItem>()
            descriptor.fetchLimit = 1
            return try container.mainContext.fetch(descriptor)[0]
        }catch{
            fatalError("Unable to fatch single item \(error)")
        }
    }
    actor DownloaderActor {
        private var downloadLock = false
        var isLocaked:Bool{
            return downloadLock
        }
        func lock() async{
            downloadLock = true
        }
        func unlock() async {
            downloadLock = false
        }
        func tryAndLock() async -> Bool{
            guard !downloadLock else{
                return false
            }
            downloadLock = true
            return true
        }
    }
    static let downloader = DownloaderActor()
    @MainActor
    static func fetchAllAndInsert(finished:@escaping ()->Void = {}){
        let shared = PersistenceSwiftController.shared
        let viewContext = shared.container.mainContext
        Task{
            guard await downloader.tryAndLock() else {
                print("Download already in progress! ...")
                return
            }
            let start = Date.now
            print("[Tasks] Starting to fetch data: \(start)")
            var downloadtasks: [Task<Void,Error>] = []
            do {
                
                for i in 1..<150 {
                    let poke_t = try await fetchPokeData(i)
                    let newItem = PokeItem()
                    newItem.id = poke_t.id
                    newItem.name = poke_t.name
                    newItem.types = poke_t.types
                    newItem.hp = poke_t.hp
                    newItem.attack = poke_t.attack
                    newItem.defence = poke_t.defense
                    newItem.specialAttack = poke_t.specialAttack
                    newItem.specialDefense = poke_t.specialDefense
                    newItem.speed = poke_t.speed
                    newItem.spriteURL = poke_t.spriteURL
                    newItem.shinyURL = poke_t.shinyURL
                    
                    viewContext.insert(newItem)

                    downloadtasks.append(Task
                    {
                        let _ = try await shared.downloadImage(newItem.id, name: poke_t.name, url: newItem.spriteURL, sprite: true)
                        let _ = try await shared.downloadImage(newItem.id, name: poke_t.name, url: newItem.shinyURL, sprite: false)
                    })
                   
                }
                try viewContext.save()
                //Swift Data takes twice time for update
                print("[Tasks] finished with json \(Date.now)")
                for dtask in downloadtasks {
                    let _ = await dtask.result
                }
                print("[Tasks] finished with downloads \(Date.now)")
                await MainActor.run{
                    finished()
                }
                
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
            await downloader.unlock()
            print("[Tasks] finished fetchin data in: \((Date.now.timeIntervalSince(start)))")
        }
    }
    static func fetchPokeData(_ index: Int) async throws -> PokeTransportItem  {
        guard let url = URL(string:"https://pokeapi.co/api/v2/pokemon/")?.appending(path: "\(index)") else {
            throw Exception.CommunicationException("Unable to compose URL")
        }
        let (data,response) = try await URLSession.shared.data(from: url)
        guard let http = response as? HTTPURLResponse, http.statusCode >= 200 && http.statusCode < 300 else {
            throw Exception.CommunicationException("Invalid protocol type or response code: \(response)")
        }
        print(String(data: data, encoding: .utf8)!)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return try decoder.decode(PokeTransportItem.self, from: data)
    }
    
    private func downloadImage(_ pokeItemID:Int16, name: String, url:URL?,  sprite:Bool) async throws -> UIImage?{
        let url = url
        let name = name
        
        var img:UIImage? = nil
        do{
            guard let url = url else{
                throw Exception.CommunicationException("Missing sprite url")
            }
            img = try await self.downloadImage(url)
            let data = img!.pngData()
            
            try await MainActor.run{
                
                var descriptor = FetchDescriptor<PokeItem>(predicate: #Predicate { $0.id == pokeItemID })
                descriptor.fetchLimit = 1
                let _pokeItem = try container.mainContext.fetch(descriptor)[0]
                    if(sprite){
                        _pokeItem.spriteRaw = data
                    }else{
                        _pokeItem.shinyRaw = data
                    }
//                    try self.container.mainContext.save()
                }
            print("Downloaded \(sprite ? "SPRITE" : "SHINY") image for \(name)")
            
        }catch{
            print("Unable to download sprite image data for \(String(describing:name))")
            throw error
        }
        return img
    }
    
    private func downloadImage(_ link:String)async throws -> UIImage{
        guard let url = URL(string: link) else {
            throw Exception.CommunicationException("Invalid link format")
        }
        return try await downloadImage(url)
    }
    private func downloadImage(_ url:URL)async throws -> UIImage{
        
        let (data,response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 else {
            throw Exception.CommunicationException("Inavlid response: \(response)")
        }
        guard let image = UIImage(data: data) else{
            throw Exception.CommunicationException("Unable to compose image from data")
        }
        return image
    }
    
   
}
