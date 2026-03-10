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
}

struct UpdatePostRequest: Encodable {
    let title: String?
    let description: String?
    let archived: Bool?
}
