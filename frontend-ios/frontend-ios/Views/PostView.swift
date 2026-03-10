//
//  PostView.swift
//  frontend-ios
//
//  Created by Sofia Guerra on 2026-03-08.
//

import Foundation
import SwiftUI
import Photos

struct PostView: View {
    let post: Post
    
    let authorName: String
    let authorUsername: String
    let authorProfileImageURL: String?
    
    @State private var isFollowing: Bool
    @State private var isLiked: Bool
    @State private var likesCount: Int
    @State private var commentsCount: Int
    
    @State private var showComments = false
    @State private var showMenuMessage = false
    @State private var menuMessage = ""
    
    init(
        post: Post,
        authorName: String,
        authorUsername: String,
        authorProfileImageURL: String? = nil,
        isFollowing: Bool = false,
        isLiked: Bool = false,
        likesCount: Int = 0,
        commentsCount: Int = 0
    ) {
        self.post = post
        self.authorName = authorName
        self.authorUsername = authorUsername
        self.authorProfileImageURL = authorProfileImageURL
        _isFollowing = State(initialValue: isFollowing)
        _isLiked = State(initialValue: isLiked)
        _likesCount = State(initialValue: likesCount)
        _commentsCount = State(initialValue: commentsCount)
    }
    
    var body: some View {
          VStack(alignment: .leading, spacing: 14) {
              
              HStack(alignment: .center, spacing: 12) {
                  profileImage
                  
                  VStack(alignment: .leading, spacing: 2) {
                      Text(authorName)
                          .font(.headline)
                          .foregroundColor(.white)
                      
                      Text("@\(authorUsername)")
                          .font(.subheadline)
                          .foregroundColor(.gray)
                  }
                  
                  Spacer()
                  
                  if !isFollowing {
                      Button {
                          followUser()
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
                  
                  Menu {
                      if post.imageData != nil {
                          Button {
                              downloadImage()
                          } label: {
                              Label("Download image", systemImage: "arrow.down.circle")
                          }
                      }
                      
                      if !composedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                          Button {
                              copyText()
                          } label: {
                              Label("Copy text", systemImage: "doc.on.doc")
                          }
                      }
                  } label: {
                      Image(systemName: "ellipsis")
                          .font(.title3)
                          .foregroundColor(.white)
                          .padding(.horizontal, 4)
                  }
              }
              
              if !post.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                  Text(post.title)
                      .font(.title3.weight(.bold))
                      .foregroundColor(.white)
                      .multilineTextAlignment(.leading)
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
                      .frame(height: 300)
                      .clipped()
                      .clipShape(RoundedRectangle(cornerRadius: 22))
              }
              
              HStack(spacing: 20) {
                  Button {
                      toggleLike()
                  } label: {
                      HStack(spacing: 6) {
                          Image(systemName: isLiked ? "heart.fill" : "heart")
                          Text("\(likesCount)")
                      }
                      .font(.subheadline.weight(.semibold))
                      .foregroundColor(isLiked ? .red : .white)
                  }
                  
                  Button {
                      showComments.toggle()
                  } label: {
                      HStack(spacing: 6) {
                          Image(systemName: "bubble.right")
                          Text("\(commentsCount)")
                      }
                      .font(.subheadline.weight(.semibold))
                      .foregroundColor(.white)
                  }
                  
                  Spacer()
              }
              .padding(.top, 4)
          }
          .padding()
          .background(
              RoundedRectangle(cornerRadius: 24)
                  .fill(Color(white: 0.12))
          )
          .overlay(
              RoundedRectangle(cornerRadius: 24)
                  .stroke(Color.white.opacity(0.08), lineWidth: 1)
          )
          .confirmationDialog(menuMessage, isPresented: $showMenuMessage, titleVisibility: .visible) {
              Button("OK", role: .cancel) { }
          }
          .sheet(isPresented: $showComments) {
              CommentsView(postId: post.id ?? "")
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
      
      private func followUser() {
          isFollowing = true
          
          // Luego aquí conectas Firebase / Firestore
          // Example:
          // FollowService.shared.follow(userId: post.userId)
      }
      
      private func toggleLike() {
          isLiked.toggle()
          likesCount += isLiked ? 1 : -1
          
          // Luego aquí conectas Firebase / Firestore
          // Example:
          // LikeService.shared.toggleLike(postId: post.id, userId: ...)
      }
      
      private func copyText() {
          UIPasteboard.general.string = composedText
          menuMessage = "Text copied"
          showMenuMessage = true
      }
      
      private var composedText: String {
          let title = post.title.trimmingCharacters(in: .whitespacesAndNewlines)
          let description = post.description.trimmingCharacters(in: .whitespacesAndNewlines)
          
          if !title.isEmpty && !description.isEmpty {
              return "\(title)\n\n\(description)"
          } else if !title.isEmpty {
              return title
          } else {
              return description
          }
      }
      
      private func downloadImage() {
          guard let data = post.imageData,
                let uiImage = UIImage(data: data) else {
              menuMessage = "No image available"
              showMenuMessage = true
              return
          }
          
          UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil)
          menuMessage = "Image saved to Photos"
          showMenuMessage = true
      }
  }



//esto debe de venir de firebase o de la db. igual que con la cuenta de likes y comentarios
#Preview {
    let samplePost = Post(
        userId: "user_123",
        title: "I am visiting Montreal and saw this weird building",
        creationDate: Date(),
        editionDate: nil,
        description: "Does anybody know what this building is? It looks really unusual from the water.",
        hidden: false,
        imageData: nil,
        latitude: nil,
        longitude: nil
    )
    
    ScrollView {
        PostView(
            post: samplePost,
            authorName: "r/montreal",
            authorUsername: "montreal",
            isFollowing: false,
            isLiked: false,
            likesCount: 749,
            commentsCount: 228
        )
        .padding()
    }
}
