//
//  DexApp.swift
//  Dex
//
//  Created by Yan  on 23/12/2025.
//

import SwiftUI

@main
struct PokeDbApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
