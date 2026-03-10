//
//  Post+APIMapper.swift
//  frontend-ios
//
//  Created by Lennin Sabogal on 10/03/26.
//

import Foundation

extension Post {
    init(apiItem: PostResponseItem) {
        self.init(
            userId: apiItem.attributes.userId ?? "",
            title: apiItem.attributes.title,
            creationDate: Date(
                timeIntervalSince1970: (apiItem.attributes.createdAt ?? 0) / 1000
            ),
            editionDate: apiItem.attributes.updatedAt != nil
            ? Date(timeIntervalSince1970: (apiItem.attributes.updatedAt ?? 0) / 1000)
            : nil,
            description: apiItem.attributes.description ?? "",
            hidden: apiItem.attributes.archived ?? false,
            imageData: nil,
            latitude: nil,
            longitude: nil
        )
    }
}
