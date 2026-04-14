//
//  LikesView.swift
//  frontend-ios
//
//  Created by Sofia Guerra on 2026-03-08.
//

import SwiftUI

struct LikesView: View {
    @StateObject private var authService = AuthService.shared
    @State private var bgColor: String = ThemeStore.shared.loadColor()
    
    @State private var items: [LikeActivityItem] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            Color(hex: bgColor)
                .ignoresSafeArea()
                .onAppear {
                    bgColor = ThemeStore.shared.loadColor()
                }

            if isLoading && items.isEmpty {
                ProgressView()
                    .tint(.white)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Latest likes on your posts")
                            .font(.title3.weight(.semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        if let errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.footnote)
                        }

                        if items.isEmpty {
                            Text("No likes yet")
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        } else {
                            ForEach(items) { item in
                                LikeActivityCard(item: item)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .task {
            await loadLikesIfNeeded()
        }
    }

    private func loadLikesIfNeeded() async {
        if authService.currentUser == nil {
            await withCheckedContinuation { continuation in
                authService.fetchCurrentAppUser { _ in
                    continuation.resume()
                }
            }
        }

        loadLikes()
    }

    private func loadLikes() {
        guard let currentUserId = authService.currentUser?.id else {
            errorMessage = "Missing current user"
            return
        }

        isLoading = true
        errorMessage = nil

        LikeService.shared.fetchLikes(targetUserId: currentUserId, limit: 50) { result in
            switch result {
            case .success(let likes):
                let likerIds = likes.compactMap(\.attributes.userId)

                ProfileService.shared.fetchProfiles(userIds: likerIds) { profileResult in
                    DispatchQueue.main.async {
                        self.isLoading = false

                        let profilesById: [String: ProfileSummary]
                        switch profileResult {
                        case .success(let profiles):
                            profilesById = profiles
                        case .failure(let error):
                            profilesById = [:]
                            self.errorMessage = error.localizedDescription
                        }

                        self.items = likes.map { like in
                            let likerId = like.attributes.userId ?? ""
                            let summary = profilesById[likerId]

                            return LikeActivityItem(
                                id: like.id,
                                likerName: summary?.authorName ?? summary?.authorUsername ?? likerId,
                                likerUsername: summary?.authorUsername ?? likerId,
                                likerProfileImageURL: summary?.authorProfileImageURL,
                                postTitle: like.attributes.postTitle ?? "your post",
                                createdAt: Date(
                                    timeIntervalSince1970: (like.attributes.createdAt ?? 0) / 1000
                                )
                            )
                        }
                    }
                }

            case .failure(let error):
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                    self.items = []
                }
            }
        }
    }
}

private struct LikeActivityItem: Identifiable {
    let id: String
    let likerName: String
    let likerUsername: String
    let likerProfileImageURL: String?
    let postTitle: String
    let createdAt: Date
}

private struct LikeActivityCard: View {
    let item: LikeActivityItem

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            profileImage

            VStack(alignment: .leading, spacing: 4) {
                Text("\(item.likerName) liked \"\(item.postTitle)\"")
                    .foregroundColor(.white)
                    .font(.body)

                Text("@\(item.likerUsername) · \(item.createdAt.formatted(date: .abbreviated, time: .shortened))")
                    .foregroundColor(.gray)
                    .font(.caption)
            }

            Spacer()

            Image(systemName: "heart.fill")
                .foregroundColor(.red)
        }
        .padding()
        .background(Color(white: 0.18))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var profileImage: some View {
        Group {
            if let urlString = item.likerProfileImageURL,
               let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    default:
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .frame(width: 44, height: 44)
        .clipShape(Circle())
    }
}

#Preview {
    LikesView()
}
