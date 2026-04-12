//
//  FeedView.swift
//  frontend-ios
//
//  Created by Sofia Guerra on 2026-03-10.
//

import Foundation
import Combine
import SwiftUI

@MainActor
final class FeedViewModel: ObservableObject {
    @Published var feedPosts: [FeedPost] = []
    @Published var errorMessage: String?

    func loadPosts() {
        loadFeedPosts()
    }

    func refreshPosts() async {
        await withCheckedContinuation { continuation in
            loadFeedPosts {
                continuation.resume()
            }
        }
    }

    func prependPost(_ createdPost: PostResponseItem) {
        let post = Post(apiItem: createdPost)

        if feedPosts.contains(where: { $0.id == post.id }) {
            return
        }

        ProfileService.shared.fetchProfiles(userIds: [post.userId]) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let profilesById):
                    let summary = profilesById[post.userId]

                    let feedPost = FeedPost(
                        id: post.id,
                        post: post,
                        authorName: summary?.authorName ?? summary?.email ?? post.userId,
                        authorUsername: summary?.authorUsername ?? summary?.email ?? post.userId,
                        authorProfileImageURL: summary?.authorProfileImageURL
                    )

                    self.feedPosts.insert(feedPost, at: 0)

                case .failure(let error):
                    let feedPost = FeedPost(
                        id: post.id,
                        post: post,
                        authorName: post.userId,
                        authorUsername: post.userId,
                        authorProfileImageURL: nil
                    )

                    self.feedPosts.insert(feedPost, at: 0)
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func loadFeedPosts(completion: (() -> Void)? = nil) {
        PostService.shared.fetchPosts(limit: 20) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedPosts):
                    self.enrichFeedPosts(from: fetchedPosts) { feedPosts, errorMessage in
                        self.feedPosts = feedPosts
                        self.errorMessage = errorMessage
                        completion?()
                    }

                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    completion?()
                }
            }
        }
    }

    private func enrichFeedPosts(
        from fetchedPosts: [PostResponseItem],
        completion: @escaping ([FeedPost], String?) -> Void
    ) {
        let mappedPosts = fetchedPosts
            .map { Post(apiItem: $0) }
            .sorted { $0.creationDate > $1.creationDate }

        let userIds = mappedPosts.map(\.userId)

        let group = DispatchGroup()
        let stateQueue = DispatchQueue(label: "FeedViewModel.enrich.state")
        var profilesById: [String: ProfileSummary] = [:]
        var errors: [String] = []

        group.enter()
        ProfileService.shared.fetchProfiles(userIds: userIds) { result in
            stateQueue.async {
                switch result {
                case .success(let profiles):
                    profilesById = profiles
                case .failure(let error):
                    errors.append(error.localizedDescription)
                }

                group.leave()
            }
        }

        group.notify(queue: .main) {
            let feedPosts = mappedPosts.map { post -> FeedPost in
                let summary = profilesById[post.userId]

                return FeedPost(
                    id: post.id,
                    post: post,
                    authorName: summary?.authorName ?? summary?.email ?? post.userId,
                    authorUsername: summary?.authorUsername ?? summary?.email ?? post.userId,
                    authorProfileImageURL: summary?.authorProfileImageURL
                )
            }

            completion(feedPosts, errors.isEmpty ? nil : errors.joined(separator: "\n"))
        }
    }
}
