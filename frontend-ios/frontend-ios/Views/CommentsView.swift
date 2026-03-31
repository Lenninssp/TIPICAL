//
//  CommentsView.swift
//  frontend-ios
//
//  Created by Sofia Guerra on 2026-03-08.
//
import SwiftUI

struct CommentsView: View {
    let postId: String
    var showsHeader: Bool = false
    var onCountChanged: ((Int) -> Void)? = nil

    @State private var comments: [Comment] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if showsHeader {
                Text("Comments")
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.white)
                    .padding(.bottom, 12)
            }

            if isLoading && comments.isEmpty {
                ProgressView()
                    .tint(.white)
                    .padding(.bottom, 12)
            }

            if let errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.footnote)
                    .padding(.bottom, 12)
            }

            if !isLoading && comments.isEmpty {
                Text("No comments yet")
                    .foregroundColor(.gray)
                    .padding(.bottom, 12)
            }

            LazyVStack(alignment: .leading, spacing: 18) {
                ForEach(comments) { comment in
                    CommentRow(comment: comment)
                }
            }
            .padding(.bottom, 12)
        }
        .task(id: postId) {
            loadComments()
        }
    }

    private func loadComments() {
        guard !postId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            comments = []
            onCountChanged?(0)
            return
        }

        isLoading = true
        errorMessage = nil

        CommentService.shared.fetchComments(postId: postId) { result in
            switch result {
            case .success(let fetchedComments):
                let userIds = fetchedComments.compactMap(\.attributes.userId)

                ProfileService.shared.fetchProfiles(userIds: userIds) { profileResult in
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

                        self.comments = fetchedComments.map { item in
                            let userId = item.attributes.userId ?? ""
                            let summary = profilesById[userId]

                            return Comment(
                                apiItem: item,
                                userName: summary?.authorName ?? summary?.authorUsername ?? userId,
                                userProfileImageURL: summary?.authorProfileImageURL
                            )
                        }

                        self.onCountChanged?(self.comments.count)
                    }
                }

            case .failure(let error):
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.comments = []
                    self.errorMessage = error.localizedDescription
                    self.onCountChanged?(0)
                }
            }
        }
    }
}
