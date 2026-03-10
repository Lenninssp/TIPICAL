//
//  CommentsView.swift
//  frontend-ios
//
//  Created by Sofia Guerra on 2026-03-08.
//

import SwiftUI

import SwiftUI

struct CommentsView: View {
    let postId: String
    
    var body: some View {
        VStack{
            Color(white: 0.12)
                .ignoresSafeArea()
            
            NavigationStack {
                Text("Comments for post: \(postId)")
                    .padding()
                    .navigationTitle("Comments")
            }
            
        }
    }
}

//#Preview {
//    CommentsView()
//}
