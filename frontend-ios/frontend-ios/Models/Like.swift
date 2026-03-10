//
//  Like.swift
//  frontend-ios
//
//  Created by Sofia Guerra on 2026-03-09.
//

import Foundation
import FirebaseFirestore

struct Like: Identifiable, Codable {
    
    @DocumentID var id: String?
    
    let creationDate: Date
    let postId: String
    let userId: String
    
}
