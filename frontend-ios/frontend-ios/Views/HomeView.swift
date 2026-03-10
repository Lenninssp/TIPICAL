//
//  HomeView.swift
//  frontend-ios
//
//  Created by Sofia Guerra on 2026-03-08.
//

import SwiftUI

struct HomeView: View {
    
    @State private var feedPosts: [FeedPost] = []
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
                    
                    ForEach(feedPosts) { item in
                        PostView(
                            post: item.post,
                            authorName: item.authorName,
                            authorUsername: item.authorUsername,
                            authorProfileImageURL: item.authorProfileImageURL,
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
                    let mappedPosts = fetchedPosts
                        .map { Post(apiItem: $0) }
                        .sorted { $0.creationDate > $1.creationDate }
                    
                    let userIds = mappedPosts.map { $0.userId }
                    
                    ProfileService.shared.fetchProfiles(userIds: userIds) { profileResult in
                        DispatchQueue.main.async {
                            switch profileResult {
                            case .success(let profilesById):
                                self.feedPosts = mappedPosts.map { post in
                                    let summary = profilesById[post.userId]
                                    
                                    return FeedPost(
                                        id: post.id,
                                        post: post,
                                        authorName: summary?.authorName ?? summary?.email ?? post.userId,
                                        authorUsername: summary?.authorUsername ?? summary?.email ?? post.userId,
                                        authorProfileImageURL: summary?.authorProfileImageURL
                                    )
                                }
                                self.errorMessage = nil
                                
                            case .failure(let error):
                                self.feedPosts = mappedPosts.map { post in
                                    FeedPost(
                                        id: post.id,
                                        post: post,
                                        authorName: post.userId,
                                        authorUsername: post.userId,
                                        authorProfileImageURL: nil
                                    )
                                }
                                self.errorMessage = error.localizedDescription
                            }
                        }
                    }
                    
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
