//
//  User.swift
//  frontend-ios
//
//  Created by Sofia Guerra on 2026-02-10.
//

import Foundation
import FirebaseFirestore

struct AppUser: Identifiable, Codable {
    
    @DocumentID var id: String?
    let email: String
    var displayName: String
    var isActive: Bool = true
    
}
