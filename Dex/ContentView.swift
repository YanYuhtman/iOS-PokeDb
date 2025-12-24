//
//  ContentView.swift
//  Dex
//
//  Created by Yan  on 23/12/2025.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \PokeItem.id, ascending: true)],
        animation: .default)
    
    private var items: FetchedResults<PokeItem>

    var body: some View {
        NavigationView {
            List {
                ForEach(items) { item in
                    NavigationLink(destination: {
                        PokeDetails(pokeItem: item)
                            .environment(\.managedObjectContext, viewContext)
                    }, label: {
                        PokeListItem(pokeItem: item)
                            .environment(\.managedObjectContext, viewContext)
                    })
//                    NavigationLink {
//                        Text("The pokeName is \(item.name!)")
//                    } label: {
//                        Text(item.timestamp!, formatter: itemFormatter)
//                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Update", systemImage: "sparkles")
                    }
                }
            }
            Text("Select an item")
        }
    }

    private func addItem() {
        withAnimation {
            
//            let newItem = PokeItem(context: viewContext)
//            newItem.timestamp = Date()

            do {
                PersistenceController.fetchAllAndInsert()
//                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    //Test Commit
}
