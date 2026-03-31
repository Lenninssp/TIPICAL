//
//  SearchUserRow.swift
//  frontend-ios
//
//  Created by Sofia Guerra on 2026-03-31.
//
import SwiftUI

struct SearchUserRow: View {
    let user: AppUser
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .frame(width: 44, height: 44)
                .foregroundColor(.gray)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(user.displayName)
                    .foregroundColor(.white)
                    .font(.headline)
                
                Text("@\(user.displayName)")
                    .foregroundColor(.gray)
                    .font(.subheadline)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white.opacity(0.04))
        .cornerRadius(12)
    }
}
