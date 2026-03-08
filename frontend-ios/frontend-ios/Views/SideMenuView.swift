//
//  SideMenuView.swift
//  frontend-ios
//
//  Created by Sofia Guerra on 2026-03-08.
//

import SwiftUI

struct SideMenuView: View {
    @Binding var showMenu: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            HStack {
                Text("Menu")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button {
                    withAnimation {
                        showMenu = false
                    }
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                        .font(.headline)
                }
            }
            .padding()
            
            Divider()
                .overlay(Color.white.opacity(0.15))
            
            menuButton(icon: "person.crop.circle", title: "Edit Profile")
            menuButton(icon: "bookmark", title: "Saved Posts")
            menuButton(icon: "bell", title: "Notifications")
            menuButton(icon: "gearshape", title: "Settings")
            menuButton(icon: "questionmark.circle", title: "Help")
            menuButton(icon: "rectangle.portrait.and.arrow.right", title: "Log Out")
            
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
