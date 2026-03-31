//
//  CommentsView.swift
//  frontend-ios
//
//  Created by Sofia Guerra on 2026-03-08.
//import SwiftUI

import SwiftUI

struct CommentsView: View {
    let postId: String
    var showsHeader: Bool = false
    
    @State private var commentText: String = ""
    
    @State private var comments: [Comment] = [
        Comment(
            postId: "1",
            userId: "u1",
            userName: "Sofia",
            creationDate: Date(),
            content: "I really like this post"
        ),
        Comment(
            postId: "1",
            userId: "u2",
            userName: "Alex",
            creationDate: Date(),
            content: "This is such a nice publication"
        ),
        Comment(
            postId: "1",
            userId: "u3",
            userName: "Marie",
            creationDate: Date(),
            content: "It looks really good"
        )
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if showsHeader {
                Text("Comments")
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.white)
                    .padding(.bottom, 12)
            }
            
            LazyVStack(alignment: .leading, spacing: 18) {
                ForEach(Array(comments.enumerated()), id: \.offset) { _, comment in
                    CommentRow(comment: comment)
                }
            }
            .padding(.bottom, 12)
            
            Divider()
                .overlay(Color.white.opacity(0.08))
                .padding(.bottom, 10)
            
            commentBar
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
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 26))
                        .foregroundColor(
                            commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            ? .gray
                            : .white
                        )
                }
                .disabled(commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color.white.opacity(0.06))
            .clipShape(Capsule())
        }
    }
    
    private func addComment() {
        let trimmed = commentText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        let newComment = Comment(
            postId: postId,
            userId: "currentUserId",
            userName: "Current User",
            creationDate: Date(),
            content: trimmed
        )
        
        comments.append(newComment)
        commentText = ""
    }
}
