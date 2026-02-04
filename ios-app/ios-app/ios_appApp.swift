//
//  ios_appApp.swift
//  ios-app
//
//  Created by Lennin Sabogal on 3/02/26.
//

import SwiftUI
import CoreData

@main
struct ios_appApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
