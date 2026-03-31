//
//  ProfilePostThumbnailView.swift
//  frontend-ios
//
//  Created by Sofia Guerra on 2026-03-08.
//

import SwiftUI

struct ProfilePostThumbnailView: View {
    let post: Post
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            thumbnailMedia
            
            LinearGradient(
                colors: [
                    Color.clear,
                    Color.black.opacity(0.78)
                ],
                startPoint: .center,
                endPoint: .bottom
            )
            .frame(height: 80)
            
            Text(post.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Untitled post" : post.title)
                .font(.caption.weight(.semibold))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
                .lineLimit(2)
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
        }
        .frame(height: 140)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    @ViewBuilder
    private var thumbnailMedia: some View {
        if let data = post.imageData,
           let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()

        } else if let imageURL = post.imageRemoteURL {
            AsyncImage(url: imageURL) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipped()

                case .failure:
                    Rectangle()
                        .fill(Color(white: 0.15))
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                        )

                default:
                    Rectangle()
                        .fill(Color(white: 0.15))
                        .overlay(
                            ProgressView()
                                .tint(.white)
                        )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()

        } else {
            Rectangle()
                .fill(Color(white: 0.15))
        }
    }
}

#Preview {
    let samplePost = Post(
        id: "1",
        userId: "user_1",
        title: "Working with technology in a new creative environment",
        creationDate: Date(),
        editionDate: nil,
        description: "Sample description",
        hidden: false,
        imageData: nil,
        latitude: nil,
        longitude: nil
    )
    
    ZStack {
        Color(white: 0.12)
            .ignoresSafeArea()
        
        ProfilePostThumbnailView(post: samplePost)
            .padding()
    }
}
