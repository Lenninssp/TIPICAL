//
//  HomeView.swift
//  frontend-ios
//
//  Created by Sofia Guerra on 2026-03-08.
//


import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject var feedViewModel: FeedViewModel
    
    var body: some View {
        ZStack {
            Color(white: 0.12)
                .ignoresSafeArea()
            
            ScrollView {
                HStack {
                    //to fixx
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
                    ForEach(feedViewModel.feedPosts) { item in
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
