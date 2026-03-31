//
//  SearchViewModel.swift
//  frontend-ios
//
//  Created by Sofia Guerra on 2026-03-31.
//

import Foundation
import FirebaseFirestore
import Combine

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var results: [AppUser] = []
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    
    func searchUsers(query: String) {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedQuery.isEmpty else {
            results = []
            errorMessage = nil
            return
        }
        
        db.collection("users").getDocuments { snapshot, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    self.results = []
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    self.results = []
                    self.errorMessage = nil
                    return
                }
                
                let users: [AppUser] = documents.compactMap { document in
                    let data = document.data()
                    
                    let email = data["email"] as? String ?? ""
                    let displayName = data["displayName"] as? String ?? ""
                    let isActive = data["isActive"] as? Bool ?? true
                    
                    return AppUser(
                        id: document.documentID,
                        email: email,
                        displayName: displayName,
                        isActive: isActive
                    )
                }
                
                self.results = users.filter { user in
                    user.displayName.lowercased().contains(trimmedQuery.lowercased())
                }
                
                self.errorMessage = nil
            }
        }
    }
    
    func clearResults() {
        results = []
        errorMessage = nil
    }
}
