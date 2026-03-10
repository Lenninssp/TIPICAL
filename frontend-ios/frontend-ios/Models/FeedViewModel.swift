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
        PostService.shared.fetchPosts(limit: 20) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedPosts):
                    let mappedPosts = fetchedPosts
                        .map { Post(apiItem: $0) }
                        .sorted { $0.creationDate > $1.creationDate }

                    let userIds = mappedPosts.map { $0.userId }

                    ProfileService.shared.fetchProfiles(userIds: userIds) { profileResult in
                        DispatchQueue.main.async {
                            switch profileResult {
                            case .success(let profilesById):
                                self.feedPosts = mappedPosts.map { post in
                                    let summary = profilesById[post.userId]

                                    return FeedPost(
                                        id: post.id,
                                        post: post,
                                        authorName: summary?.authorName ?? summary?.email ?? post.userId,
                                        authorUsername: summary?.authorUsername ?? summary?.email ?? post.userId,
                                        authorProfileImageURL: summary?.authorProfileImageURL
                                    )
                                }
                                self.errorMessage = nil

                            case .failure(let error):
                                self.feedPosts = mappedPosts.map { post in
                                    FeedPost(
                                        id: post.id,
                                        post: post,
                                        authorName: post.userId,
                                        authorUsername: post.userId,
                                        authorProfileImageURL: nil
                                    )
                                }
                                self.errorMessage = error.localizedDescription
                            }
                        }
                    }

                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
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
}
