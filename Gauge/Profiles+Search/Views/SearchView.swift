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
    @State private var navigateToSearchedUser: Bool = false
    @State private var searchedUserIsCurrUser: Bool = false

    @State var items = Array(Category.allCases.shuffled().prefix(through: min(7, Category.allCases.count - 1)))
    
    var body: some View {
        NavigationStack {
            VStack {
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
                            Button(action: {
                                searchText = ""
                                showResults = false
                                postSearchResults = []
                                selectedCategory = nil
                            }) {
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
                
                Group {
                    if let category = selectedCategory {
                        categoryPostsView(category: category)
                    } else if isSearchActive {
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
                        CategoriesView(
                            categories: $items,
                            selectedCategory: $selectedCategory,
                            isLoading: $isLoading,
                            postSearchResults: $postSearchResults,
                            errorMessage: $errorMessage
                        )
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .navigationTitle(selectedCategory != nil ? selectedCategory!.rawValue : (isSearchActive ? "" : "Explore"))
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
            .navigationDestination(isPresented: $navigateToSearchedUser) {
                ProfileView(userVM: searchedUserVM, isCurrentUser: searchedUserIsCurrUser)
            }
        }
    }
    
    @ViewBuilder
    private func categoryPostsView(category: Category) -> some View {
        if isLoading {
            ProgressView("Loading posts...")
                .padding()
        } else if let errorMessage = errorMessage {
            Text(errorMessage)
                .foregroundStyle(.red)
                .padding()
        } else if !postSearchResults.isEmpty {
            List {
                ForEach(postSearchResults) { result in
                    PostResultRow(result: result)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 6, leading: 8, bottom: 6, trailing: 8))
                }
            }
            .listStyle(.plain)
        } else {
            Text("No posts found in this category.")
                .padding()
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
    
    private func loadCategoryPosts(category: Category) {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                let results = try await searchVM.searchPostsByCategory(category)
                await MainActor.run {
                    postSearchResults = results
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to load category posts: \(error.localizedDescription)"
                    isLoading = false
                }
            }
        }
    }
}

struct SearchResultsView: View {
    @EnvironmentObject var userVM: UserFirebase
    @ObservedObject var searchedUserVM: UserFirebase
    @Binding var selectedTab: String
    @Binding var isLoading: Bool
    @Binding var errorMessage: String?
    @Binding var postSearchResults: [PostResult]
    @Binding var userSearchResults: [UserResult]
    @Binding var userSearchProfileImages: [String: UIImage]
    @Binding var navigateToSearchedUser: Bool
    @Binding var searchedUserIsCurrUser: Bool
    
    var body: some View {
        if isLoading {
            ProgressView("Searching...")
                .padding()
        } else if let errorMessage = errorMessage {
            Text(errorMessage)
                .foregroundStyle(.red)
                .padding()
        } else if (selectedTab == "Topics" && !postSearchResults.isEmpty) {
            List {
                ForEach(postSearchResults) { result in
                    PostResultRow(result: result)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 6, leading: 8, bottom: 6, trailing: 8))
                }
            }
            .listStyle(.plain)
        } else if (selectedTab == "Users" && !userSearchResults.isEmpty) {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(userSearchResults) { user in
                    HStack {
                        ZStack {
                            if let userProfileImage = userSearchProfileImages[user.id] {
                                Image(uiImage: userProfileImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                            } else {
                                Circle()
                                    .fill(Color.gray)
                                    .frame(width: 40, height: 40)
                            }
                        }
                        Text(user.username)
                            .padding(5)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white)
                            .cornerRadius(10)
                    }
                    .onTapGesture {
                        Task {
                            do {
                                let fetchedUser = try await searchedUserVM.getUserData(userId: user.id)
                                // Update the user on the main thread if needed:
                                await MainActor.run {
                                    searchedUserVM.user = fetchedUser
                                }
                            } catch {
                                print("Error fetching user data: \(error.localizedDescription)")
                            }
                        }

                    }
                }
            }
            .padding()
        } else {
            Text("No results found.")
                .padding()
        }
    }
}

struct CategoriesView: View {
    @Binding var categories: [Category]
    @Binding var selectedCategory: Category?
    @Binding var isLoading: Bool
    @Binding var postSearchResults: [PostResult]
    @Binding var errorMessage: String?
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Categories")
                .font(.headline)
                .bold()
                .padding(.horizontal)
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(categories, id: \.self) { category in
                        Button(action: {
                            selectedCategory = category
                            loadCategoryPosts(category: category)
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(.systemGray5))
                                    .frame(height: 100)
                                Text(category.rawValue)
                                    .foregroundColor(.black)
                                    .font(.headline)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private func loadCategoryPosts(category: Category) {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                let results = try await SearchViewModel().searchPostsByCategory(category)
                await MainActor.run {
                    postSearchResults = results
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to load category posts: \(error.localizedDescription)"
                    isLoading = false
                }
            }
        }
    }
}

struct RecentSearchesView: View {
    @FocusState.Binding var isSearchFieldFocused: Bool
    @Binding var searchText: String
    @Binding var selectedTab: String
    
    @State private var recentTopics = ["SwiftUI", "Firebase", "iOS", "Combine", "Xcode"]
    @State private var recentUsers = ["Datta", "Amber", "Austin", "Akshat", "Shreeya"]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Recent")
                .font(.headline)
                .padding(.leading)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    if selectedTab == "Topics" {
                        ForEach(Array(recentTopics.enumerated()), id: \.element) { index, topic in
                            HStack {
                                Image(systemName: "number")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.black)
                                    .padding(8)
                                    .background(Color(.systemGray5))
                                    .clipShape(Circle())
                                
                                Text(topic)
                                    .padding(5)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.white)
                                    .cornerRadius(10)
                                
                                Button(action: {
                                    recentTopics.remove(at: index)
                                }) {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 12, weight: .regular))
                                        .foregroundColor(Color(.systemGray))
                                        .padding()
                                }
                            }
                        }
                    } else {
                        ForEach(Array(recentUsers.enumerated()), id: \.element) { index, user in
                            HStack {
                                Circle()
                                    .fill(Color(.systemGray))
                                    .frame(width: 40, height: 40)
                                
                                Text(user)
                                    .padding(5)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.white)
                                    .cornerRadius(10)
                                
                                Button(action: {
                                    recentUsers.remove(at: index)
                                }) {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 12, weight: .regular))
                                        .foregroundColor(Color(.systemGray))
                                        .padding()
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            
            HStack {
                Picker(selection: $selectedTab, label: Text("")) {
                    ForEach(["Topics", "Users"], id: \.self) { tab in
                        Text(tab).tag(tab)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 300)
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
    }
}

#Preview {
    SearchView()
}
