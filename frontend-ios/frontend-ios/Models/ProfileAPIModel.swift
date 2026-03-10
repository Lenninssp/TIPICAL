//
//  ProfileAPIModel.swift
//  frontend-ios
//
//  Created by Lennin Sabogal on 10/03/26.
//

import Foundation

struct ProfileAttributes: Codable {
    let id: String?
    let email: String?
    let username: String?
    let firstName: String?
    let lastName: String?
    let description: String?
    let birthDate: Double?
    let profilePicture: String?
    let creationDate: Double?
    let lastLoginDate: Double?
}

struct ProfileResponseItem: Codable, Identifiable {
    let id: String
    let type: String
    let attributes: ProfileAttributes
}
