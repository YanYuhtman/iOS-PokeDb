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

    @State var filter:String = ""
    @State var showOnlyVavorites:Bool = false
    @State var disableUpdate:Bool = false
    
    var filtered:[PokeItem]{
        
        items.filter{ pokeItem in
            let showByfavorite = showOnlyVavorites ? pokeItem.favorite : true
            return showByfavorite &&
            (pokeItem.name!.lowercased().contains(filter.lowercased()) || filter.isEmpty)
        }
    }
    var body: some View {
        NavigationView {
            List {
                ForEach(filtered) { item in
                    NavigationLink(destination: {
                        PokeDetails(pokeItem: item)
                            .environment(\.managedObjectContext, viewContext)
                    }, label: {
                        PokeListItem(pokeItem: item)
                            .environment(\.managedObjectContext, viewContext)
                            .swipeActions(edge:.leading){
                                Button(item.favorite ? "Remove from\nFavorites" : "Add to \nFavorites") {
                                    item.favorite.toggle()
                                    do{
                                        try viewContext.save()
                                    }catch{
                                        print("Unable to save to favorites \(String(describing: item.name))")
                                    }
                                }.tint(item.favorite ? Color.gray : Color.yellow)
                            }
                    })
//                    NavigationLink {
//                        Text("The pokeName is \(item.name!)")
//                    } label: {
//                        Text(item.timestamp!, formatter: itemFormatter)
//                    }
                }
                
                .onDelete(perform: deleteItems)
            }
            .navigationTitle("Pokies")
            .searchable(text: $filter, prompt: "Filter items")
            //The code is fine. XCode bugged
            .onChange(of: filter){filter in
                if filter.isEmpty{
                    showOnlyVavorites = false
                }
            }
            .toolbar {
                ToolbarItem {
                    Button(action:{
                        showOnlyVavorites.toggle()
                    }){
                        Label("Favoritest", systemImage: showOnlyVavorites ? "star.fill": "star")
                    }
                }
                ToolbarItem {
                    Button(action: fetchItems) {
                        Label("Update", systemImage: "sparkles")
                    }.disabled(disableUpdate)
                }
            }
            Text("Select an item")
        }
    }

    private func fetchItems() {
        disableUpdate = true
        withAnimation {
            
            //            let newItem = PokeItem(context: viewContext)
            //            newItem.timestamp = Date()
            
            do {
                PersistenceController.fetchAllAndInsert(finished: {
                    disableUpdate = false
                })
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
