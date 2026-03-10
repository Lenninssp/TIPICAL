//
//  SearchView.swift
//  frontend-ios
//
//  Created by Sofia Guerra on 2026-03-08.
//

import SwiftUI
import Foundation

struct SearchView: View {
    
    @State private var searchText: String = ""
    
    var body: some View {
        ZStack {
            Color(white: 0.12)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search...", text: $searchText)
                        .foregroundColor(.white)
                        .accentColor(.white)
                    
                    if !searchText.isEmpty {
                        Button {
                            searchText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding()
                .background(Color(white: 0.18))
                .cornerRadius(14)
                .padding(.horizontal)
                .padding(.top)
                
                Spacer()
            }
        }
    }
    
    private func search() {
           print("Searching for \(searchText)")
           
           // aquí haces la consulta a Firebase
       }
}

#Preview {
    SearchView()
}
