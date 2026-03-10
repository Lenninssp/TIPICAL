//
//  Untitled.swift
//  frontend-ios
//
//  Created by Lennin Sabogal on 10/03/26.
//

import Foundation

struct FeedPost: Identifiable {
    let id: String
    let post: Post
    let authorName: String
    let authorUsername: String
    let authorProfileImageURL: String?
}
