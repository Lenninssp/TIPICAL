//
//  Like.swift
//  frontend-ios
//
//  Created by Lennin Sabogal on 2026-03-31.
//

import Foundation

struct LikeAttributes: Codable {
    let id: String?
    let postId: String?
    let userId: String?
    let createdAt: Double?
}

struct LikeResponseItem: Codable, Identifiable {
    let id: String
    let type: String
    let attributes: LikeAttributes
}

struct CreateLikeRequest: Encodable {
    let postId: String
}
