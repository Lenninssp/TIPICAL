//
//  HomePageView.swift
//  frontend-ios
//
//  Created by Sofia Guerra on 2026-02-10.
//

import SwiftUI

struct HomePageView: View {
    @ObservedObject private var auth = AuthService.shared
    @State private var errorMessage: String?
    var body: some View {
        
            VStack {
                Text("TIPICAL")

                Form {
                    Button(role: .destructive) {
                        let result = auth.signOut()
                        if case .failure(let failure) = result {
                            self.errorMessage = failure.localizedDescription
                        } else {
                            self.errorMessage = nil
                        }
                    } label: {
                        Text("Sign Out")
                    }
                }
            }
            .onAppear {
                auth.fetchCurrentAppUser { _ in }
            }
        }

}

//#Preview {
//    HomePageView()
//}
