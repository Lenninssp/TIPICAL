//
//  frontend_iosApp.swift
//  frontend-ios
//
//  Created by Sofia Guerra on 2026-02-10.
//

import SwiftUI
import CoreData
import FirebaseCore


class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct frontend_iosApp: App {
//    @AppStorage("isDarkMode") var isDarkMode: Bool = true
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
//    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
//                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
