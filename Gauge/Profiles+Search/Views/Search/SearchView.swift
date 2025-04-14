//
//  SearchView.swift
//  Gauge
//
//  Created by Datta Kansal on 2/6/25.
//

import SwiftUI

struct SearchView: View {
    @EnvironmentObject var userVM: UserFirebase
    @EnvironmentObject var authVM: AuthenticationVM
    @StateObject private var searchVM = SearchViewModel()
    @StateObject var profileVM = ProfileViewModel()
    @StateObject var searchedUserVM = UserFirebase()
    
    @State private var searchText: String = ""
    @FocusState private var isSearchFieldFocused: Bool
    @State private var selectedTab: String = "Topics"
    @State private var postSearchResults: [PostResult] = []
    @State private var userSearchResults: [UserResult] = []
    @State private var userSearchProfileImages: [String: UIImage] = [:]
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    @State private var showResults: Bool = false
    @State private var isSearchActive: Bool = false

    @State private var selectedCategory: Category? = nil
    
    @State private var navigateToSearchedUser: Bool = false
    
    
    private var searchBar: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Color(.systemGray))
                
                TextField("Search", text: $searchText)
                    .foregroundColor(Color(.black))
                    .focused($isSearchFieldFocused)
                    .submitLabel(.search)
                    .onChange(of: isSearchFieldFocused) { _, focused in
                        if focused {
                            isSearchActive = true
                            selectedCategory = nil
                        }
                    }
                    .onChange(of: searchText) { newValue in
                        if selectedTab == "Users" {
                            if !newValue.isEmpty {
                                performUserSearch()
                            } else {
                                showResults = false
                            }
                        }
                    }
                    .onSubmit {
                        if !searchText.isEmpty {
                            if selectedTab == "Topics" {
                                performTopicSearch()
                            } else if selectedTab == "Users" {
                                performUserSearch()
                            }
                        }
                    }
                
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                        showResults = false
                        postSearchResults = []
                        selectedCategory = nil
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Color(.systemGray))
                    }
                }
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 5)
            .background(Color(.systemGray5))
            .cornerRadius(12)
            
            if isSearchActive {
                Button("Cancel") {
                    isSearchActive = false
                    isSearchFieldFocused = false
                    searchText = ""
                    postSearchResults = []
                    userSearchResults = []
                    showResults = false
                    selectedCategory = nil
                }
                .foregroundColor(.blue)
            }
        }
        .padding(.horizontal, 12)
        .padding(.top, 1)
        .padding(.bottom, 10)
    }
    
    private var searchContent: some View {
        Group {
            if isSearchActive {
                if showResults {
                    SearchResultsView(
                        searchedUserVM: searchedUserVM,
                        selectedTab: $selectedTab,
                        isLoading: $isLoading,
                        errorMessage: $errorMessage,
                        postSearchResults: $postSearchResults,
                        userSearchResults: $userSearchResults,
                        userSearchProfileImages: $userSearchProfileImages,
                        navigateToSearchedUser: $navigateToSearchedUser
                    )
                } else {
                    RecentSearchesView(
                        isSearchFieldFocused: $isSearchFieldFocused,
                        searchText: $searchText,
                        selectedTab: $selectedTab
                    )
                }
            } else {
                CategoriesView(
                    selectedCategory: $selectedCategory,
                    isLoading: $isLoading,
                    postSearchResults: $postSearchResults,
                    errorMessage: $errorMessage
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
    
    private var categoryDestination: some View {
        Group {
            if let category = selectedCategory {
                CategoryResultsView(category: category, onDismiss: {
                    self.selectedCategory = nil
                })
            } else {
                EmptyView()
            }
        }
    }
    
    private var categoryNavigationLink: some View {
        NavigationLink(destination: categoryDestination,
                       isActive: Binding(
            get: { selectedCategory != nil },
            set: { active in
                if !active { selectedCategory = nil }
            }
        )) {
            EmptyView()
        }
    }
    
    private var userNavigationLink: some View {
        NavigationLink(
            destination: Group {
                if searchedUserVM.user.userId == userVM.user.userId {
                    ProfileView()
                        .environmentObject(searchedUserVM)
                        .environmentObject(authVM)
                } else {
                    ProfileVisitView(user: searchedUserVM.user, friendsViewModel: FriendsViewModel(user: userVM.user))
                }
            },
            isActive: $navigateToSearchedUser
        ) {
            EmptyView()
        }
        .hidden()
    }
    
    
    var body: some View {
        NavigationStack {
            VStack {
                if selectedCategory == nil {
                    searchBar
                    searchContent
                } else {
                    EmptyView()
                }
            }
            .background(categoryNavigationLink)
            .background(userNavigationLink)
            .navigationTitle(
                selectedCategory != nil
                ? selectedCategory!.rawValue
                : (isSearchActive ? "" : "Explore")
            )
            .toolbar {
                if selectedCategory != nil {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            selectedCategory = nil
                        } label: {
                            Image(systemName: "arrow.left")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
        }
    }
    
    private func performTopicSearch() {
        isLoading = true
        showResults = true
        Task {
            do {
                let results = try await searchVM.searchPosts(for: searchText)
                await MainActor.run {
                    postSearchResults = results
                    isLoading = false
                }
                try await userVM.updateRecentPostSearch(with: searchText)
            } catch {
                await MainActor.run {
                    errorMessage = "Search failed: \(error.localizedDescription)"
                    isLoading = false
                }
            }
        }
    }
    
    private func performUserSearch() {
        isLoading = true
        showResults = true
        Task {
            do {
                let users = try await searchVM.fetchUsers(for: searchText.lowercased())
                for user in users {
                    if user.profilePhotoUrl != "" && !userSearchProfileImages.keys.contains(user.id) {
                        userSearchProfileImages[user.id] = await profileVM.getProfilePicture(userID: user.id)
                    }
                }
                await MainActor.run {
                    userSearchResults = users
                    isLoading = false
                }
                if users.isEmpty {
                    try await userVM.updateRecentProfileSearch(with: searchText)
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Search failed: \(error.localizedDescription)"
                    isLoading = false
                }
            }
        }
    }
}

#Preview {
    SearchView()
}
