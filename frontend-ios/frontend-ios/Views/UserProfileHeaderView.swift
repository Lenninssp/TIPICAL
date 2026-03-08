//
//  UserProfileHeaderView.swift
//  frontend-ios
//
//  Created by Sofia Guerra on 2026-03-08.
//

import SwiftUI

struct UserProfileHeaderView: View {
    let profileImageName: String
    let username: String
    let postsCount: Int
    let followersCount: String
    let followingCount: Int
    let bio: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            HStack(alignment: .top, spacing: 16) {
                Image(profileImageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 90, height: 90)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                
                Spacer()
                
                HStack(spacing: 22) {
                    profileStat(number: "\(postsCount)", label: "posts")
                    profileStat(number: followersCount, label: "followers")
                    profileStat(number: "\(followingCount)", label: "following")
                }
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(username)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(bio)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
            }
        }
        .padding(.horizontal)
    }
    
    private func profileStat(number: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(number)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(label)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
}

//#Preview {
//    UserProfileHeaderView()
//}
