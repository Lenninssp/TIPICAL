//
//  AuthGate.swift
//  frontend-ios
//
//  Created by Sofia Guerra on 2026-02-10.
//

import SwiftUI

struct AuthGate: View {
    @State private var showLogin = true

    var body: some View {
        VStack {
            Picker("", selection: $showLogin) {
                Text("Login").tag(true)
                Text("Register").tag(false)
            }
            .pickerStyle(.segmented)
            .padding()

            if showLogin {
                LoginView()
            } else {
                RegisterView()
            }
        }
    }
}
