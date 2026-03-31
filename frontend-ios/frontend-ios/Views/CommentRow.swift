//
//  CommentRow.swift
//  frontend-ios
//
//  Created by Sofia Guerra on 2026-03-31.
//

import SwiftUI

struct CommentRow: View {
    let comment: Comment
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(Color.gray.opacity(0.45))
                .frame(width: 42, height: 42)
                .overlay(
                    Image(systemName: "person.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 16))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(comment.userName)
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .semibold))
                    
                    Text(comment.creationDate.formatted(date: .abbreviated, time: .shortened))
                        .foregroundColor(.gray)
                        .font(.system(size: 13))
                }
                
                Text(comment.content)
                    .foregroundColor(.white)
                    .font(.system(size: 17))
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
        }
    }
}
