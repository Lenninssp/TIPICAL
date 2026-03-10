//
//  HomeView.swift
//  frontend-ios
//
//  Created by Sofia Guerra on 2026-03-08.
//

import SwiftUI

struct HomeView: View {
    
    @State private var posts: [Post] = []
    @State private var errorMessage: String?

    
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
        PostService.shared.fetchPosts(limit: 20) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedPosts):
                    print("===== RAW API IDS =====")
                    for item in fetchedPosts {
                        print("api id =", item.id)
                    }

                    let mappedPosts = fetchedPosts.map { Post(apiItem: $0) }

                    print("===== MAPPED POST IDS =====")
                    for post in mappedPosts {
                        print("mapped post id =", post.id)
                    }

                    self.posts = mappedPosts
                    self.errorMessage = nil

                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
