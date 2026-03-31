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

    @State private var commentText: String = ""
    @State private var comments: [Comment] = []
    @State private var isLoading = false
    @State private var isSubmitting = false
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

            Divider()
                .overlay(Color.white.opacity(0.08))
                .padding(.bottom, 10)

            commentBar
        }
        .task(id: postId) {
            loadComments()
        }
    }

    private var commentBar: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(Color.gray.opacity(0.4))
                .frame(width: 36, height: 36)
                .overlay(
                    Image(systemName: "person.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 14))
                )

            HStack {
                TextField(
                    "",
                    text: $commentText,
                    prompt: Text("Add a comment")
                        .foregroundColor(.gray)
                )
                .foregroundColor(.white)

                Button {
                    addComment()
                } label: {
                    if isSubmitting {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 26))
                            .foregroundColor(
                                commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                ? .gray
                                : .white
                            )
                    }
                }
                .frame(width: 26, height: 26)
                .disabled(
                    isSubmitting ||
                    commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                )
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color.white.opacity(0.06))
            .clipShape(Capsule())
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

    private func addComment() {
        let trimmed = commentText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        guard !isSubmitting else { return }

        isSubmitting = true
        errorMessage = nil

        CommentService.shared.createComment(postId: postId, comment: trimmed) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.commentText = ""
                    self.isSubmitting = false
                    self.loadComments()

                case .failure(let error):
                    self.isSubmitting = false
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
