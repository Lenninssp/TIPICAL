//
//  PostAPIModel.swift
//  frontend-ios
//
//  Created by Lennin Sabogal on 10/03/26.
//

import Foundation

struct APIResource<T: Decodable>: Decodable {
    let data: T
}

struct APIResourceList<T: Decodable>: Decodable {
    let data: [T]
}

struct PostAttributes: Codable {
    let title: String
    let description: String?
    let userId: String?
    let archived: Bool?
    let createdAt: Double?
    let updatedAt: Double?
    let editedAt: Double?
    let latitude: Double?
    let longitude: Double?
    let imageUrl: String?
    let imagePath: String?
    let likeCount: Int?
    let likedByCurrentUser: Bool?
}

struct PostResponseItem: Codable, Identifiable {
    let id: String
    let type: String
    let attributes: PostAttributes
}

struct CreatePostRequest: Encodable {
    let title: String
    let description: String
    let archived: Bool
    let latitude: Double?
    let longitude: Double?
    let imageUrl: String?
    let imagePath: String?
}

struct UpdatePostRequest: Encodable {
    let title: String?
    let description: String?
    let archived: Bool?
    let latitude: Double?
    let longitude: Double?
    let imageUrl: String?
    let imagePath: String?
}

struct UploadResponseAttributes: Codable {
    let imageUrl: String
    let imagePath: String
}

struct UploadResponseItem: Codable {
    let id: String
    let type: String
    let attributes: UploadResponseAttributes
}
