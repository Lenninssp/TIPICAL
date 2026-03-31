//
//  ContentView.swift
//  frontend-ios
//
//  Created by Sofia Guerra on 2026-02-10.
//
import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @StateObject private var auth = AuthService.shared
    @State private var isLoaded = false

    private var isFullyAuthenticated: Bool {
        Auth.auth().currentUser != nil &&
        TokenStore.shared.loadToken() != nil
    }

    var body: some View {
        NavigationView {
            Group {
                if !isLoaded {
                    ProgressView()
                        .onAppear {
                            auth.fetchCurrentAppUser { _ in
                                DispatchQueue.main.async {
                                    isLoaded = true
                                }
                            }
                        }
                }
                else if !isFullyAuthenticated {
                    AuthGate()
                }
                else {
                    MenuBarView()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
