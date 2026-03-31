//
//  Post.swift
//  frontend-ios
//
//  Created by Sofia Guerra on 2026-03-08.
//

import Foundation
import CoreLocation

struct Post: Identifiable, Codable {

    var id: String

    let userId: String
    var title: String
    var creationDate: Date
    var editionDate: Date?
    var description: String

    var hidden: Bool = false

    var imageData: Data? = nil
    var imageUrl: String? = nil
    var imagePath: String? = nil

    var latitude: Double? = nil
    var longitude: Double? = nil

    var likeCount: Int = 0
    var likedByCurrentUser: Bool = false
    var commentsCount: Int = 0

    var imageRemoteURL: URL? {
        guard let imageUrl,
              !imageUrl.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return nil
        }

        return URL(string: imageUrl)
    }

    var coordinate: CLLocationCoordinate2D? {
        guard let latitude, let longitude else {
            return nil
        }

        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
