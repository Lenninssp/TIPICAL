//
//  PostDetailedContentView.swift
//  frontend-ios
//
//  Created by Sofia Guerra on 2026-03-31.
//

import SwiftUI
import CoreLocation

struct PostDetailedContentView: View {
    let post: Post
    let authorName: String
    let authorUsername: String
    let authorProfileImageURL: String?

    @Binding var isFollowing: Bool
    @Binding var isLiked: Bool
    @Binding var likesCount: Int
    @Binding var commentsCount: Int

    @State private var isUpdatingLike = false

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

    @ViewBuilder
    private var postMedia: some View {
        if let data = post.imageData,
           let uiImage = UIImage(data: data) {
            ZStack {
                RoundedRectangle(cornerRadius: 22)
                    .fill(Color.white.opacity(0.06))

                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit() // ✅ prevents overflow
                    .frame(maxWidth: .infinity, maxHeight: 300)
            }
            .frame(maxWidth: .infinity, maxHeight: 300)
            .clipShape(RoundedRectangle(cornerRadius: 22))

        } else if let imageURL = post.imageRemoteURL {
            AsyncImage(url: imageURL) { phase in
                ZStack {
                    RoundedRectangle(cornerRadius: 22)
                        .fill(Color.white.opacity(0.06))

                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit() // ✅ prevents overflow
                            .frame(maxWidth: .infinity, maxHeight: 300)

                    case .failure:
                        Image(systemName: "photo")
                            .foregroundColor(.gray)

                    default:
                        ProgressView()
                            .tint(.white)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 300)
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
                    print("Like toggle failed:", error.localizedDescription)
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
        imageUrl: nil,
        imagePath: nil,
        latitude: nil,
        longitude: nil,
        likeCount: 12,
        likedByCurrentUser: false,
        commentsCount: 4
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
