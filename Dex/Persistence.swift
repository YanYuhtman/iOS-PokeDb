//
//  Persistence.swift
//  Dex
//
//  Created by Yan  on 23/12/2025.
//
import Foundation
import CoreData
import UIKit

enum Exception : Error{
    case CommunicationException(_ message:String)
}

struct PersistenceController {
    static let shared: PersistenceController = {
        let result = PersistenceController()
        let context = result.container.viewContext
        
        context.automaticallyMergesChangesFromParent = true
        context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        return result
    }()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        let newItem = PokeItem(context: viewContext)
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
        
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
    
    @MainActor
    static func fetchItemForPreveiw()->PokeItem {
        do{
            let request = NSFetchRequest<PokeItem>(entityName: "PokeItem")
            request.fetchLimit = 1
            let items = try PersistenceController.preview.container.viewContext.fetch(request)
            return items[0]
        }catch{
            fatalError("Unable to fetch item for preview \(error)")
        }
    }


    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Dex")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    func saveContext(){
        do{
            try self.container.viewContext.save()
        }catch{
            print("Unable to save persistant data \(error)")
        }
    }
    @MainActor
    static func fetchAllAndInsert(){
        let shared = shared
        let viewContext = shared.container.viewContext
        Task{
            do {
                
                for i in 1..<150 {
                    let poke_t = try await fetchPokeData(i)
                    let newItem = PokeItem(context: viewContext)
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
                    
                    try viewContext.save()
                }
                try await shared.downloadAllImages()
                
                
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
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
    func downloadAllImages()async throws{
        
        let items = try container.viewContext.fetch(PokeItem.fetchRequest())
        
        try await withThrowingTaskGroup(of: UIImage?.self){ group in
            for item in items {
                let id = item.objectID
                let name = item.name ?? "UNKNOWN"
                let spriteURL = item.spriteURL
                let shinyURL = item.shinyURL
                group.addTask{
                    try await downloadImage(id,name: name, url: spriteURL, sprite: true)
                }
                group.addTask{
                    try await downloadImage(id,name: name, url:shinyURL, sprite: false)
                }
            }
            try await group.waitForAll()
        }
        
    }
    private func downloadImage(_ pokeID:NSManagedObjectID, name: String, url:URL?,  sprite:Bool) async throws -> UIImage?{
        let url = url
        let id = pokeID
        let name = name
        
        var img:UIImage? = nil
        do{
            guard let url = url else{
                throw Exception.CommunicationException("Missing sprite url")
            }
            img = try await downloadImage(url)
            let data = img!.pngData()
            
            try await MainActor.run{
                if let pokeItem = try container.viewContext.existingObject(with: id) as? PokeItem{
                    pokeItem.spriteRaw = data
                    try? self.container.viewContext.save()
                }
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
