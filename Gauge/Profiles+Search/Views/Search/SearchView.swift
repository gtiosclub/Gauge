import SwiftUI

struct SearchView: View {
    @EnvironmentObject var userVM: UserFirebase
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
    @State private var navigateToCategory: Bool = false
    
    @State private var navigateToSearchedUser: Bool = false
    @State private var searchedUserIsCurrUser: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                if selectedCategory == nil {
                    HStack {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(Color(.systemGray))
                            
                            TextField("Search", text: $searchText)
                                .foregroundColor(Color(.black))
                                .focused($isSearchFieldFocused)
                                .submitLabel(.search)
                                .onChange(of: isSearchFieldFocused, initial: false) { _, focused in
                                    if focused {
                                        isSearchActive = true
                                        selectedCategory = nil
                                    }
                                }
                                .onSubmit {
                                    if selectedTab == "Topics", !searchText.isEmpty {
                                        performTopicSearch()
                                    }
                                }
                                .onChange(of: searchText, initial: false) { _, text in
                                    if selectedTab == "Users" {
                                        if !text.isEmpty {
                                            performUserSearch()
                                        } else {
                                            showResults = false
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
                
                Group {
                    if selectedCategory == nil {
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
                                    navigateToSearchedUser: $navigateToSearchedUser,
                                    searchedUserIsCurrUser: $searchedUserIsCurrUser
                                )
                            } else {
                                RecentSearchesView(
                                    isSearchFieldFocused: $isSearchFieldFocused,
                                    searchText: $searchText,
                                    selectedTab: $selectedTab
                                )
                            }
                        } else {
                            // Show CategoriesView.
                            CategoriesView(
                                selectedCategory: $selectedCategory,
                                isLoading: $isLoading,
                                postSearchResults: $postSearchResults,
                                errorMessage: $errorMessage
                            )
                        }
                    } else {
                        EmptyView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .background(
                NavigationLink(
                    destination: ProfileView(userVM: searchedUserVM, isCurrentUser: searchedUserIsCurrUser),
                    isActive: $navigateToSearchedUser
                ) {
                    EmptyView()
                }
                .hidden()
            )
            .background(
                NavigationLink(
                    destination: Group {
                        if let category = selectedCategory {
                            CategoryResultsView(category: category, onDismiss: {
                                selectedCategory = nil
                            })
                        } else {
                            EmptyView()
                        }
                    },
                    isActive: Binding(
                        get: { selectedCategory != nil },
                        set: { newValue in
                            if !newValue { selectedCategory = nil }
                        }
                    )
                ) {
                    EmptyView()
                }
                .hidden()
            )
            .onChange(of: selectedCategory) { newValue in
                navigateToCategory = (newValue != nil)
            }
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
            .navigationDestination(for: Category.self) { category in
                CategoryResultsView(category: category)
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
