//
//  ProfileView.swift
//  frontend-ios
//
//  Created by Sofia Guerra on 2026-03-08.
//

import SwiftUI

struct ProfileView: View {
    @State private var showSideMenu = false
    
    //sample data borrar
    let posts: [Post] = [
        Post(
            userId: "user_1",
            title: "Exploring ancient places",
            creationDate: Date(),
            editionDate: nil,
            description: "A fascinating archaeological site.",
            hidden: false,
            imageData: nil,
            latitude: nil,
            longitude: nil
        ),
        Post(
            userId: "user_1",
            title: "A beautiful landscape",
            creationDate: Date(),
            editionDate: nil,
            description: "Nature is amazing.",
            hidden: false,
            imageData: nil,
            latitude: nil,
            longitude: nil
        ),
        Post(
            userId: "user_1",
            title: "Working with technology",
            creationDate: Date(),
            editionDate: nil,
            description: "A productive day.",
            hidden: false,
            imageData: nil,
            latitude: nil,
            longitude: nil
        )
    ]
    
    let columns = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2)
    ]
    
    var body: some View {
        ZStack(alignment: .trailing) {
            NavigationStack {
                ZStack {
                    Color(white: 0.12)
                        .ignoresSafeArea()
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            
                            // Header
                            HStack {
                                Spacer()
                                
                                Button {
                                    withAnimation {
                                        showSideMenu = true
                                    }
                                } label: {
                                    Image(systemName: "line.3.horizontal")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                }
                            }
                            .padding(.horizontal)
                            
                            //to fix
                            
                            UserProfileHeaderView(
                                profileImageName: "logo",
                                username: "TheSpaceThnow",
                                postsCount: 422,
                                followersCount: "254 mil",
                                followingCount: 4,
                                bio: """
                                Creador digital
                                • Come On Guys Let's Explore Universe
                                • Science & Astronomy
                                """
                            )
                            
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Posts")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                                
                                LazyVGrid(columns: columns, spacing: 2) {
                                    ForEach(posts) { post in
                                        ProfilePostThumbnailView(post: post)
                                    }
                                }
                            }
                        }
                        .padding(.top, 10)
                    }
                }
                .navigationBarHidden(true)
            }
            
            if showSideMenu {
                Color.black.opacity(0.45)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            showSideMenu = false
                        }
                    }
                
                SideMenuView(showMenu: $showSideMenu)
                    .transition(.move(edge: .trailing))
            }
        }
    }
}

#Preview {
    ProfileView()
}
