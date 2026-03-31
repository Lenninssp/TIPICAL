//
//  DetailledPostView.swift
//  frontend-ios
//
//  Created by Sofia Guerra on 2026-03-31.
//
import SwiftUI

struct DetailedPostView: View {
    let post: Post
    let authorName: String
    let authorUsername: String
    let authorProfileImageURL: String?
    
    @State var isFollowing: Bool
    @State var isLiked: Bool
    @State var likesCount: Int
    @State var commentsCount: Int
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color(white: 0.12)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.title3.weight(.semibold))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        PostDetailedContentView(
                            post: post,
                            authorName: authorName,
                            authorUsername: authorUsername,
                            authorProfileImageURL: authorProfileImageURL,
                            isFollowing: $isFollowing,
                            isLiked: $isLiked,
                            likesCount: $likesCount,
                            commentsCount: $commentsCount
                        )
                        
                        Divider()
                            .overlay(Color.white.opacity(0.08))
                        
                        Text("Comments")
                            .font(.title3.weight(.semibold))
                            .foregroundColor(.white)
                        
                        CommentsView(
                            postId: post.id,
                            showsHeader: false,
                            onCountChanged: { commentsCount = $0 }
                        )
                    }
                    .padding()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}
