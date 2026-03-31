//
//  PostDetailedContentView.swift
//  frontend-ios
//
//  Created by Sofia Guerra on 2026-03-31.
//

import SwiftUI

struct PostDetailedContentView: View {
    let post: Post
    let authorName: String
    let authorUsername: String
    let authorProfileImageURL: String?
    
    @Binding var isFollowing: Bool
    @Binding var isLiked: Bool
    @Binding var likesCount: Int
    @Binding var commentsCount: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center, spacing: 12) {
                NavigationLink {
                    ProfileView(
                        viewedUserId: post.userId,
                        viewedAuthorName: authorName,
                        viewedAuthorUsername: authorName,
                        viewedAuthorProfileImageURL: authorProfileImageURL
                    )
                } label: {
                    HStack(alignment: .center, spacing: 12) {
                        profileImage
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(authorName)
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text("@\(authorName)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .buttonStyle(.plain)
           
                
                Spacer()
                
                if !isFollowing {
                    Button {
                        isFollowing = true
                    } label: {
                        Text("Follow")
                            .font(.subheadline.weight(.semibold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .stroke(Color.white.opacity(0.4), lineWidth: 1)
                            )
                    }
                    .foregroundColor(.white)
                }
            }
            
            if !post.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Text(post.title)
                    .font(.title2.weight(.bold))
                    .foregroundColor(.white)
            }
            
            if !post.description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Text(post.description)
                    .font(.body)
                    .foregroundColor(.white)
            }
            
            if let image = postImage {
                image
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 320)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 22))
            }
            
            HStack(spacing: 20) {
                Button {
                    isLiked.toggle()
                    likesCount += isLiked ? 1 : -1
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                        Text("\(likesCount)")
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(isLiked ? .red : .white)
                }
                
                HStack(spacing: 6) {
                    Image(systemName: "bubble.right")
                    Text("\(commentsCount)")
                }
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.white)
            }
            .padding(.top, 4)
        }
    }
    
    private var postImage: Image? {
        guard let data = post.imageData,
              let uiImage = UIImage(data: data) else {
            return nil
        }
        return Image(uiImage: uiImage)
    }
    
    private var profileImage: some View {
        Group {
            if let urlString = authorProfileImageURL,
               let url = URL(string: urlString) {
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
                            .padding(6)
                    }
                }
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.gray)
                    .padding(6)
            }
        }
        .frame(width: 46, height: 46)
        .background(Color(white: 0.18))
        .clipShape(Circle())
    }
}

#Preview {
    @Previewable @State var isFollowing = false
    @Previewable @State var isLiked = false
    @Previewable @State var likesCount = 12
    @Previewable @State var commentsCount = 4
    
    let samplePost = Post(
        id: "1",
        userId: "user_1",
        title: "A detailed post example",
        creationDate: Date(),
        editionDate: nil,
        description: "This is a longer post body to preview how the detailed content view will look when it is opened from the feed or profile.",
        hidden: false,
        imageData: nil,
        latitude: nil,
        longitude: nil
    )
    
    NavigationStack {
        ZStack {
            Color(white: 0.12)
                .ignoresSafeArea()
            
            PostDetailedContentView(
                post: samplePost,
                authorName: "Sofia Guerra",
                authorUsername: "sofiaguerra",
                authorProfileImageURL: nil,
                isFollowing: $isFollowing,
                isLiked: $isLiked,
                likesCount: $likesCount,
                commentsCount: $commentsCount
            )
            .padding()
        }
    }
}
