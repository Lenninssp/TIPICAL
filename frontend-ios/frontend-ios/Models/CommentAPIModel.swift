//
//  CommentAPIModel.swift
//  frontend-ios
//

import Foundation

struct CommentAttributes: Codable {
    let id: String?
    let postId: String?
    let userId: String?
    let comment: String?
    let hidden: Bool?
    let creationDate: Double?
    let editionDate: Double?
}

struct CommentResponseItem: Codable, Identifiable {
    let id: String
    let type: String
    let attributes: CommentAttributes
}

struct CreateCommentRequest: Encodable {
    let postId: String
    let comment: String
}

struct UpdateCommentRequest: Encodable {
    let comment: String?
    let hidden: Bool?
}
