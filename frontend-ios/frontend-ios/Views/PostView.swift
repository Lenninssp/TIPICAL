//
//  PostView.swift
//  frontend-ios
//
//  Created by Sofia Guerra on 2026-03-08.
//

import Foundation
import SwiftUI
import Photos
import CoreLocation

struct PostView: View {
    let post: Post

    let authorName: String
    let authorUsername: String
    let authorProfileImageURL: String?

    @State private var isFollowing: Bool
    @State private var isLiked: Bool
    @State private var likesCount: Int
    @State private var commentsCount: Int

    @State private var showMenuMessage = false
    @State private var menuMessage = ""
    @State private var isUpdatingLike = false

    private let maxDescriptionLength = 120

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
                    if post.imageData != nil || post.imageRemoteURL != nil {
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
                Text(displayedDescription)
                    .font(.body)
                    .foregroundColor(.white)

                if shouldShowSeeMore {
                    NavigationLink {
                        DetailedPostView(
                            post: post,
                            authorName: authorName,
                            authorUsername: authorUsername,
                            authorProfileImageURL: authorProfileImageURL,
                            isFollowing: isFollowing,
                            isLiked: isLiked,
                            likesCount: likesCount,
                            commentsCount: commentsCount
                        )
                    } label: {
                        Text("See more")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .underline()
                    }
                }
            }

            postMedia

            if let coordinateText {
                Label(coordinateText, systemImage: "mappin.and.ellipse")
                    .font(.footnote)
                    .foregroundColor(.gray)
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
                .disabled(isUpdatingLike)

                NavigationLink {
                    DetailedPostView(
                        post: post,
                        authorName: authorName,
                        authorUsername: authorUsername,
                        authorProfileImageURL: authorProfileImageURL,
                        isFollowing: isFollowing,
                        isLiked: isLiked,
                        likesCount: likesCount,
                        commentsCount: commentsCount
                    )
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
    }

    private var shouldShowSeeMore: Bool {
        post.description.count > maxDescriptionLength
    }

    private var displayedDescription: String {
        if shouldShowSeeMore {
            return String(post.description.prefix(maxDescriptionLength)) + "..."
        }
        return post.description
    }

    @ViewBuilder
    private var postMedia: some View {
        if let data = post.imageData,
           let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .frame(maxHeight: 300)
                .clipShape(RoundedRectangle(cornerRadius: 22))
        } else if let imageURL = post.imageRemoteURL {
            AsyncImage(url: imageURL) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()

                case .failure:
                    RoundedRectangle(cornerRadius: 22)
                        .fill(Color.white.opacity(0.06))
                        .frame(maxWidth: .infinity, maxHeight: 300)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                        )

                default:
                    RoundedRectangle(cornerRadius: 22)
                        .fill(Color.white.opacity(0.06))
                        .frame(maxWidth: .infinity, maxHeight: 300)
                        .overlay(
                            ProgressView()
                                .tint(.white)
                        )
                }
            }
            .frame(maxWidth: .infinity)
            .frame(maxHeight: 300)
            .clipShape(RoundedRectangle(cornerRadius: 22))
        }
    }

    private var coordinateText: String? {
        guard let coordinate = post.coordinate else {
            return nil
        }

        return String(format: "%.5f, %.5f", coordinate.latitude, coordinate.longitude)
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
    }

    private func toggleLike() {
        guard !isUpdatingLike else { return }

        let newLikedState = !isLiked
        isUpdatingLike = true
        isLiked = newLikedState
        likesCount = max(0, likesCount + (newLikedState ? 1 : -1))

        let completion: (Result<Void, Error>) -> Void = { result in
            DispatchQueue.main.async {
                self.isUpdatingLike = false

                if case .failure(let error) = result {
                    self.isLiked.toggle()
                    self.likesCount = max(0, self.likesCount + (newLikedState ? -1 : 1))
                    self.menuMessage = error.localizedDescription
                    self.showMenuMessage = true
                }
            }
        }

        if newLikedState {
            LikeService.shared.likePost(postId: post.id) { result in
                completion(result.map { _ in () })
            }
        } else {
            LikeService.shared.unlikePost(postId: post.id, completion: completion)
        }
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
        if let data = post.imageData,
           let uiImage = UIImage(data: data) {
            UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil)
            menuMessage = "Image saved to Photos"
            showMenuMessage = true
            return
        }

        guard let imageURL = post.imageRemoteURL else {
            menuMessage = "No image available"
            showMenuMessage = true
            return
        }

        URLSession.shared.dataTask(with: imageURL) { data, _, error in
            guard let data, error == nil, let uiImage = UIImage(data: data) else {
                DispatchQueue.main.async {
                    self.menuMessage = "Failed to download image"
                    self.showMenuMessage = true
                }
                return
            }

            UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil)
            DispatchQueue.main.async {
                self.menuMessage = "Image saved to Photos"
                self.showMenuMessage = true
            }
        }.resume()
    }
}
