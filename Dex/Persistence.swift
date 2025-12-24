//
//  Persistence.swift
//  Dex
//
//  Created by Yan  on 23/12/2025.
//

import CoreData

enum Exception : Error{
    case CommunicationException(_ message:String)
}

struct PersistenceController {
    static let shared: PersistenceController = {
        let result = PersistenceController()
        let context = result.container.viewContext
        
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
    @MainActor
    static func fetchAllAndInsert(){
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
}
