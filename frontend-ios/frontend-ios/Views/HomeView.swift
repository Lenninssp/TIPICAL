//
//  HomeView.swift
//  frontend-ios
//
//  Created by Sofia Guerra on 2026-03-08.
//
import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject var feedViewModel: FeedViewModel
    @State private var bgColor: String = ThemeStore.shared.loadColor()

    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: bgColor)
                    .ignoresSafeArea()
                    .onAppear {
                        bgColor = ThemeStore.shared.loadColor()
                    }
                
                ScrollView {
                    HStack {
                        Image(.logo)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                        
                        Text("TYPICAL")
                            .bold()
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    .padding(.top, 8)
                    
                    LazyVStack(spacing: 20) {
//                        Text("Posts count: \(feedViewModel.feedPosts.count)")
//                            .foregroundColor(.white)
                        ForEach(feedViewModel.feedPosts) { item in
                            PostView(
                                post: item.post,
                                authorName: item.authorName,
                                authorUsername: item.authorUsername,
                                authorProfileImageURL: item.authorProfileImageURL,
                                isFollowing: false,
                                isLiked: item.post.likedByCurrentUser,
                                likesCount: item.post.likeCount,
                                commentsCount: item.post.commentsCount
                            )
                        }
                    }
                    .padding()
                }
                .refreshable {
                    await feedViewModel.refreshPosts()
                }
            }
            .onAppear {
                if feedViewModel.feedPosts.isEmpty {
                    feedViewModel.loadPosts()
                }
            }
        }
    }
}
