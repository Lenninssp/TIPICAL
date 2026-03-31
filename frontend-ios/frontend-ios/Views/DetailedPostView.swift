//
//  DetailledPostView.swift
//  frontend-ios
//
//  Created by Sofia Guerra on 2026-03-31.
//
import SwiftUI

struct DetailedPostView: View {
    let post: Post
    let authorName: String
    let authorUsername: String
    let authorProfileImageURL: String?
    var onLikeStateChanged: ((Bool, Int) -> Void)? = nil
    var onCommentCountChanged: ((Int) -> Void)? = nil

    @State var isFollowing: Bool
    @State var isLiked: Bool
    @State var likesCount: Int
    @State var commentsCount: Int

    @State private var commentText: String = ""
    @State private var isSubmittingComment = false
    @State private var commentErrorMessage: String?
    @State private var commentsReloadToken = UUID()

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color(white: 0.12)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.title3.weight(.semibold))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                    }

                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 8)

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        PostDetailedContentView(
                            post: post,
                            authorName: authorName,
                            authorUsername: authorUsername,
                            authorProfileImageURL: authorProfileImageURL,
                            isFollowing: $isFollowing,
                            isLiked: $isLiked,
                            likesCount: $likesCount,
                            commentsCount: $commentsCount
                        )

                        Divider()
                            .overlay(Color.white.opacity(0.08))

                        Text("Comments")
                            .font(.title3.weight(.semibold))
                            .foregroundColor(.white)

                        if let commentErrorMessage {
                            Text(commentErrorMessage)
                                .foregroundColor(.red)
                                .font(.footnote)
                        }

                        CommentsView(
                            postId: post.id,
                            showsHeader: false,
                            onCountChanged: { commentsCount = $0 }
                        )
                        .id(commentsReloadToken)
                    }
                    .padding()
                    .padding(.bottom, 90) // space for fixed comment bar
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            commentBarContainer
        }
        .navigationBarBackButtonHidden(true)
        .onChange(of: isLiked) { _, _ in
            onLikeStateChanged?(isLiked, likesCount)
        }
        .onChange(of: likesCount) { _, _ in
            onLikeStateChanged?(isLiked, likesCount)
        }
        .onChange(of: commentsCount) { _, newValue in
            onCommentCountChanged?(newValue)
        }
    }

    private var commentBarContainer: some View {
        VStack(spacing: 0) {
            Divider()
                .overlay(Color.white.opacity(0.08))

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
                        if isSubmittingComment {
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
                        isSubmittingComment ||
                        commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    )
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color.white.opacity(0.06))
                .clipShape(Capsule())
            }
            .padding(.horizontal)
            .padding(.top, 10)
            .padding(.bottom, 50)
            .background(Color(white: 0.12))
        }
    }

    private func addComment() {
        let trimmed = commentText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        guard !isSubmittingComment else { return }

        isSubmittingComment = true
        commentErrorMessage = nil

        CommentService.shared.createComment(postId: post.id, comment: trimmed) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.commentText = ""
                    self.isSubmittingComment = false
                    self.commentsReloadToken = UUID()
                    self.commentsCount += 1

                case .failure(let error):
                    self.isSubmittingComment = false
                    self.commentErrorMessage = error.localizedDescription
                }
            }
        }
    }
}
