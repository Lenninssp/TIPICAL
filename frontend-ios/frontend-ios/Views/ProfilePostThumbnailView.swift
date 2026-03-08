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
        ZStack {
            if let data = post.imageData,
               let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 140)
                    .frame(maxWidth: .infinity)
                    .clipped()
            } else {
                Rectangle()
                    .fill(Color(white: 0.15))
                    .frame(height: 140)
                    .overlay(
                        VStack(spacing: 8) {
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                                .font(.title2)
                            
                            Text(post.title)
                                .font(.caption)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                                .padding(.horizontal, 6)
                        }
                    )
            }
        }
    }
}
