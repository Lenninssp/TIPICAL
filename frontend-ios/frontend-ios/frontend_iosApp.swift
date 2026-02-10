//
//  frontend_iosApp.swift
//  frontend-ios
//
//  Created by Sofia Guerra on 2026-02-10.
//

import SwiftUI
import CoreData

@main
struct frontend_iosApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
