//
//  HomeView.swift
//  frontend-ios
//
//  Created by Sofia Guerra on 2026-03-08.
//

import SwiftUI

struct HomeView: View {
    
    @State private var posts: [Post] = []
    
    var body: some View {
        
        ZStack {
            
            Color(white: 0.12)
                .ignoresSafeArea()
            
            ScrollView {
                HStack{
                    //to fixxx
                    Image(.logo)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                    
                    Text("TYPICAL")
                        .bold()
                        .font(.title2)
                        .foregroundColor(.white)
                }
               
                
                LazyVStack(spacing: 20) {
                    
                    ForEach(posts) { post in
                        PostView(
                            post: post,
                            authorName: "User",
                            authorUsername: "user123",
                            isFollowing: false,
                            isLiked: false,
                            likesCount: 0,
                            commentsCount: 0
                        )
                    }
                }
                .padding()
            }
        }
        .onAppear {
            loadPosts()
        }
    }
    
    func loadPosts() {
        let examplePost = Post(
            userId: "123",
            title: "Example title",
            creationDate: Date(),
            editionDate: nil,
            description: "Example description",
            hidden: false,
            imageData: nil,
            latitude: nil,
            longitude: nil
        )
        
        posts = [examplePost, examplePost, examplePost]
    }
}

#Preview {
    HomeView()
}
