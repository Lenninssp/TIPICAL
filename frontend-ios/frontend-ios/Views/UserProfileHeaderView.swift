//
//  UserProfileHeaderView.swift
//  frontend-ios
//
//  Created by Sofia Guerra on 2026-03-08.
//

import SwiftUI

struct UserProfileHeaderView: View {
    let profileImageURL: String?
    let username: String
    let displayName: String
    let postsCount: Int
    let followersCount: String
    let followingCount: Int
    let bio: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            HStack(alignment: .top, spacing: 16) {
                profileImage
                
                Spacer()
                
                HStack(spacing: 22) {
                    profileStat(number: "\(postsCount)", label: "posts")
                    //profileStat(number: followersCount, label: "followers")
                    //profileStat(number: "\(followingCount)", label: "following")
                }
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(displayName)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("@\(username)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                if !bio.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text(bio)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                }
            }
        }
        .padding(.horizontal)
    }
    
    private var profileImage: some View {
        Group {
            if let profileImageURL,
               let url = URL(string: profileImageURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    default:
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.gray)
                            .padding(8)
                    }
                }
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.gray)
                    .padding(8)
            }
        }
        .frame(width: 90, height: 90)
        .background(Color(white: 0.18))
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
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

#Preview {
    ZStack {
        Color(white: 0.12)
            .ignoresSafeArea()
        
        UserProfileHeaderView(
            profileImageURL: nil,
            username: "sofiaguerra",
            displayName: "Sofia Guerra",
            postsCount: 12,
            followersCount: "254",
            followingCount: 8,
            bio: "Digital creator\n• Science & technology"
        )
        .padding(.top, 30)
    }
}
