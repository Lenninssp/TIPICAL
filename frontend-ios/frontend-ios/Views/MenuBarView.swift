//
//  MenuBarView.swift
//  frontend-ios
//
//  Created by Sofia Guerra on 2026-03-08.
//

import SwiftUI

struct MenuBarView: View {
    
    @State private var selectedTab: Tab = .home
    @State private var showCreatePost = false
    @EnvironmentObject var feedViewModel: FeedViewModel
    
    
    enum Tab {
        case home
        case search
        case likes
        case profile
    }
    
    var body: some View {
        
        ZStack(alignment: .bottom) {
            
            Color(white: 0.12)
                .ignoresSafeArea()
        
            Group {
                switch selectedTab {
                case .home:
                    HomeView()
                case .search:
                    SearchView()
                case .likes:
                    LikesView()
                case .profile:
                    ProfileView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea(.keyboard)
            
        
            VStack(spacing: 0) {
                Divider()
                
                HStack {
                    tabButton(
                        icon: "house.fill",
                        title: "Home",
                        tab: .home
                    )
                    
                    Spacer()
                    
                    tabButton(
                        icon: "magnifyingglass",
                        title: "Search",
                        tab: .search
                    )
                    
                    Spacer()
                    
                    Button {
                          showCreatePost = true
                      } label: {
                          Image(systemName: "plus")
                                  .font(.system(size: 22,weight: .semibold))
                                  .foregroundColor(.gray)
                                  .frame(width: 35, height: 35)
                                  .overlay(
                                      RoundedRectangle(cornerRadius: 10)
                                          .stroke(Color.gray, lineWidth: 1)
                                  )
                      }
                      .offset(y: -5)
                    
                    
                    Spacer()
                    
                    tabButton(
                        icon: "heart",
                        title: "Likes",
                        tab: .likes
                    )

                                        
                    Spacer()
                    
                    tabButton(
                        icon: "person.crop.circle.fill",
                        title: "Profile",
                        tab: .profile
                    )
                }
                .padding(.horizontal, 30)
                .padding(.top, 12)
                .padding(.bottom, 20)
                .frame(maxWidth: .infinity)
                .background(Color(white: 0.12))
            }
            .frame(maxWidth: .infinity)
            

        }
        .ignoresSafeArea(.container, edges: .bottom)
        .sheet(isPresented: $showCreatePost) {
                    CreatePostView()
                        .environmentObject(feedViewModel)
                }
    }
    

    @ViewBuilder
private func tabButton(icon: String, title: String, tab: Tab) -> some View {
    Button {
        selectedTab = tab
    } label: {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
            
            Text(title)
                .font(.caption2)
        }
        .foregroundColor(selectedTab == tab ? .blue : .gray)
    }
}
}

struct MenuBarView_Previews: PreviewProvider {
    static var previews: some View {
        MenuBarView()
    }
}
