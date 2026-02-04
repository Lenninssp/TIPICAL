//
//  front_ios_appApp.swift
//  front-ios-app
//
//  Created by Lennin Sabogal on 10/02/26.
//

import SwiftUI
import CoreData

@main
struct front_ios_appApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
