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
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct frontend_iosApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var feedViewModel = FeedViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(feedViewModel)
        }
    }
}
