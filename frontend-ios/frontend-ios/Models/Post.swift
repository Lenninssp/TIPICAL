//
//  Post.swift
//  frontend-ios
//
//  Created by Sofia Guerra on 2026-03-08.
//

import Foundation
import FirebaseFirestore
import CoreLocation

struct Post: Identifiable, Codable {
    
    @DocumentID var id: String?
    
    let userId: String
    var title: String
    var creationDate: Date
    var editionDate: Date?
    var description: String
    
    var hidden: Bool = false
    
    var imageData: Data?   // equivalente a Bit[]
    
    var latitude: Double?  // para MapKit
    var longitude: Double?
    
}


