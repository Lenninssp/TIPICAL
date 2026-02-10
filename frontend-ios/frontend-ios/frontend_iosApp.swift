//
//  frontend_iosApp.swift
//  frontend-ios
//
//  Created by Lennin Sabogal on 10/02/26.
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
