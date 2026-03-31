//
//  Comment.swift
//  frontend-ios
//
//  Created by Sofia Guerra on 2026-03-31.
//

import Foundation

struct Comment: Identifiable, Codable {
    let id: String
    let postId: String
    let userId: String
    let userName: String
    let userProfileImageURL: String?
    let creationDate: Date
    var content: String
}

extension Comment {
    init(
        apiItem: CommentResponseItem,
        userName: String,
        userProfileImageURL: String? = nil
    ) {
        self.init(
            id: apiItem.id,
            postId: apiItem.attributes.postId ?? "",
            userId: apiItem.attributes.userId ?? "",
            userName: userName,
            userProfileImageURL: userProfileImageURL,
            creationDate: Date(
                timeIntervalSince1970: (apiItem.attributes.creationDate ?? 0) / 1000
            ),
            content: apiItem.attributes.comment ?? ""
        )
    }
}
