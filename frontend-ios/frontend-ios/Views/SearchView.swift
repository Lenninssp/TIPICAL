//
//  SearchView.swift
//  frontend-ios
//
//  Created by Sofia Guerra on 2026-03-08.
//

import SwiftUI

struct SearchView: View {
    @State private var searchText: String = ""
    @StateObject private var viewModel = SearchViewModel()
    @State private var bgColor: String = ThemeStore.shared.loadColor()
    
    var body: some View {
        NavigationStack {
            ZStack {
                
                Color(hex: bgColor)
                    .ignoresSafeArea()
                    .onAppear {
                        bgColor = ThemeStore.shared.loadColor()
                    }
                
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Search users...", text: $searchText)
                            .foregroundColor(.white)
                            .accentColor(.white)
                            .onChange(of: searchText) { newValue in
                                viewModel.searchUsers(query: newValue)
                            }
                        
                        if !searchText.isEmpty {
                            Button {
                                searchText = ""
                                viewModel.clearResults()
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
                    
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding(.horizontal)
                        
                        Spacer()
                    } else if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Spacer()
                        
                        Text("Search for users")
                            .foregroundColor(.gray)
                        
                        Spacer()
                    } else if viewModel.results.isEmpty {
                        Spacer()
                        
                        Text("No results")
                            .foregroundColor(.gray)
                        
                        Spacer()
                    } else {
                        ScrollView {
                            VStack(spacing: 14) {
                                ForEach(viewModel.results) { user in
                                    NavigationLink {
                                        ProfileView(
                                            viewedUserId: user.id,
                                            viewedAuthorName: user.displayName,
                                            viewedAuthorUsername: user.displayName,
                                            viewedAuthorProfileImageURL: nil
                                        )
                                    } label: {
                                        SearchUserRow(user: user)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom)
                        }
                    }
                }
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    SearchView()
}
