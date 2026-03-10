//
//  LikesView.swift
//  frontend-ios
//
//  Created by Sofia Guerra on 2026-03-08.
//

import SwiftUI

struct LikesView: View {
    
    var body: some View {
        ZStack {
            
            Color(white: 0.12)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 14) {
                    
                    LikeCard(username: "Laura", profileImage: "person.circle.fill")
                    FollowCard(username: "Carlos", profileImage: "person.circle.fill")
                    LikeCard(username: "María", profileImage: "person.circle.fill")
                    
                }
                .padding()
            }
        }
    }
}

struct LikeCard: View {
    
    var username: String
    var profileImage: String
    
    var body: some View {
        
        HStack(spacing: 12) {
            
            Image(systemName: profileImage)
                .resizable()
                .scaledToFill()
                .frame(width: 44, height: 44)
                .foregroundColor(.white)
                .clipShape(Circle())
            
            Text("\(username) Liked your post")
                .foregroundColor(.white)
                .font(.body)
            
            Image(systemName: "heart.fill")
                .foregroundColor(.red)
            
            Spacer()
        }
        .padding()
        .background(Color(white: 0.18))
        .cornerRadius(12)
    }
}

struct FollowCard: View {
    
    var username: String
    var profileImage: String
    
    var body: some View {
        
        HStack(spacing: 12) {
            
            Image(systemName: profileImage)
                .resizable()
                .scaledToFill()
                .frame(width: 44, height: 44)
                .foregroundColor(.white)
                .clipShape(Circle())
            
            Text("\(username) Follows you")
                .foregroundColor(.white)
                .font(.body)
            
            Spacer()
        }
        .padding()
        .background(Color(white: 0.18))
        .cornerRadius(12)
    }
}

#Preview {
    LikesView()
}
