//
//  ProfileView.swift
//  frontend-ios
//
//  Created by Sofia Guerra on 2026-03-08.
//
import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var feedViewModel: FeedViewModel
    @StateObject private var authService = AuthService.shared
    @State private var showSideMenu = false
    @State private var bgColor: String = ThemeStore.shared.loadColor()

    let viewedUserId: String?
    let viewedAuthorName: String?
    let viewedAuthorUsername: String?
    let viewedAuthorProfileImageURL: String?

    init(
        viewedUserId: String? = nil,
        viewedAuthorName: String? = nil,
        viewedAuthorUsername: String? = nil,
        viewedAuthorProfileImageURL: String? = nil
    ) {
        self.viewedUserId = viewedUserId
        self.viewedAuthorName = viewedAuthorName
        self.viewedAuthorUsername = viewedAuthorUsername
        self.viewedAuthorProfileImageURL = viewedAuthorProfileImageURL
    }

    let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]

    private var displayedUserId: String? {
        viewedUserId ?? authService.currentUser?.id
    }

    private var currentUserPosts: [FeedPost] {
        guard let userId = displayedUserId else { return [] }

        return feedViewModel.feedPosts.filter { feedPost in
            feedPost.post.userId == userId
        }
    }

    private var profileUsername: String {
        if let viewedAuthorUsername,
           !viewedAuthorUsername.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return viewedAuthorUsername
        }

        return authService.currentUser?.displayName ?? "user"
    }

    private var profileDisplayName: String {
        if let viewedAuthorName,
           !viewedAuthorName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return viewedAuthorName
        }

        return authService.currentUser?.displayName ?? "Unknown user"
    }

    var body: some View {
        ZStack(alignment: .trailing) {
            ZStack {
                Color(hex: bgColor)
                    .ignoresSafeArea()
                    .onAppear {
                        bgColor = ThemeStore.shared.loadColor()
                    }

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
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

                        UserProfileHeaderView(
                            profileImageURL: viewedAuthorProfileImageURL,
                            username: profileUsername,
                            displayName: profileDisplayName,
                            postsCount: currentUserPosts.count,
                            followersCount: "0",
                            followingCount: 0,
                            bio: ""
                        )

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Posts")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal)

                            if currentUserPosts.isEmpty {
                                Text("No posts yet")
                                    .foregroundColor(.gray)
                                    .padding(.horizontal)
                            } else {
                                LazyVGrid(columns: columns, spacing: 8) {
                                    ForEach(currentUserPosts) { feedPost in
                                        NavigationLink {
                                            DetailedPostView(
                                                post: feedPost.post,
                                                authorName: feedPost.authorName,
                                                authorUsername: feedPost.authorUsername,
                                                authorProfileImageURL: feedPost.authorProfileImageURL,
                                                isFollowing: true,
                                                isLiked: feedPost.post.likedByCurrentUser,
                                                likesCount: feedPost.post.likeCount,
                                                commentsCount: feedPost.post.commentsCount
                                            )
                                        } label: {
                                            ProfilePostThumbnailView(post: feedPost.post)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if authService.currentUser == nil {
                    authService.fetchCurrentAppUser { _ in }
                }

                if feedViewModel.feedPosts.isEmpty {
                    feedViewModel.loadPosts()
                }
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
    NavigationStack {
        ProfileView()
            .environmentObject(FeedViewModel())
    }
}
