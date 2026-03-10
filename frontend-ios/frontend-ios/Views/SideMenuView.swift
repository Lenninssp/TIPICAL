//
//  SideMenuView.swift
//  frontend-ios
//
//  Created by Sofia Guerra on 2026-03-08.
//

import SwiftUI

struct SideMenuView: View {
    @Binding var showMenu: Bool
    @ObservedObject private var auth = AuthService.shared
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            HStack {
                Text("Menu")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
//                Button {
//                    withAnimation {
//                        showMenu = false
//                    }
//                } label: {
//                    Image(systemName: "xmark")
//                        .foregroundColor(.white)
//                        .font(.headline)
//                }
            }
            .padding()
            
            Divider()
                .overlay(Color.white.opacity(0.15))
            
            menuButton(icon: "person.crop.circle", title: "Edit Profile")
           // menuButton(icon: "bookmark", title: "Saved Posts")
            menuButton(icon: "gearshape", title: "Settings")
            menuButton(icon: "questionmark.circle", title: "Help")
            //menuButton(icon: "rectangle.portrait.and.arrow.right", title: "Log Out")
            logoutButton()
            
            Spacer()
        }
        .frame(width: 260)
        .frame(maxHeight: .infinity)
        .background(Color(white: 0.08))
        .overlay(
            Rectangle()
                .fill(Color.white.opacity(0.08))
                .frame(width: 1),
            alignment: .leading
        )
    }
    
    private func logoutButton() -> some View {
            Button {
                let result = AuthService.shared.signOut { result in
                    switch result {
                    case .success:
                        print("Signed out")
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
                
                
            } label: {
                HStack(spacing: 14) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .frame(width: 20)
                        .foregroundColor(.red)
                    
                    Text("Log Out")
                        .foregroundColor(.red)
                        .font(.body)
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 16)
            }
        }
    
    
    private func menuButton(icon: String, title: String) -> some View {
        Button {
            print("\(title) tapped")
        } label: {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .frame(width: 20)
                    .foregroundColor(.white)
                
                Text(title)
                    .foregroundColor(.white)
                    .font(.body)
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 16)
        }
    }
}
