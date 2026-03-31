//
//  Comment.swift
//  frontend-ios
//
//  Created by Sofia Guerra on 2026-03-31.
//

import SwiftUI
import FirebaseFirestore

struct Comment: Identifiable, Codable {
    @DocumentID var id: String?
    
    let postId: String
    let userId: String
    let userName: String
    let creationDate: Date
    var content: String
}
