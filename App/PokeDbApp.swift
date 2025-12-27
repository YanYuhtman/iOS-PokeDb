//
//  DexApp.swift
//  Dex
//
//  Created by Yan  on 23/12/2025.
//

import SwiftUI
import SwiftData

@main
struct PokeDbApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }.modelContainer(PersistenceSwiftController.shared.container)
    }
}
