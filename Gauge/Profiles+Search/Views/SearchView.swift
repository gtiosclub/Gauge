//
//  SearchView.swift
//  Gauge
//
//  Created by Anthony Le on 2/25/25.
//

import SwiftUI

struct SearchView: View {
    @StateObject private var searchVM = SearchViewModel()
    @State private var searchText: String = ""
    @FocusState private var isSearchFieldFocused: Bool
    @State private var selectedTab: String = "Topics"
    @State private var postSearchResults: [PostResult] = []
    @State private var userSearchResults: [UserResult] = []
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    @State private var showResults: Bool = false
    @State private var isSearchActive: Bool = false

    @State var items = Array(Category.allCategoryStrings.shuffled().prefix(through: 19))
    
    var body: some View {
        NavigationStack {
            VStack {
                // Search Bar
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
                                }
                            }
                            .onChange(of: searchText, initial: false) { _, text in
                                if (selectedTab == "Users") {
                                    isLoading = true
                                    showResults = true
                                    Task {
                                        do {
                                            let userSeach = try await searchVM.fetchUsers(for: searchText)
                                            await MainActor.run {
                                                userSearchResults = userSeach
                                                isLoading = false
                                            }
                                        } catch {
                                            await MainActor.run {
                                                errorMessage = "Search failed: \(error.localizedDescription)"
                                            }
                                        }
                                    }
                                }
                            }
                            .onSubmit {
                                if (selectedTab == "Topics") {
                                    if !searchText.isEmpty {
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
                                }
                            }

                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                                showResults = false
                                postSearchResults = []
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(Color(.systemGray))
                            }
                        }
                    }
                    .padding(.horizontal, 4)  // Reduced horizontal padding
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
                        }
                        .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal, 4)
                .padding(.top, 1)
                .padding(.bottom, 10)
                
                Group {
                    if isSearchActive {
                        if showResults {
                            SearchResultsView(selectedTab: $selectedTab, isLoading: $isLoading, errorMessage: $errorMessage, postSearchResults: $postSearchResults, userSearchResults: $userSearchResults)
                        } else {
                            RecentSearchesView(isSearchFieldFocused: $isSearchFieldFocused,
                                               searchText: $searchText,
                                               selectedTab: $selectedTab)
                        }
                    } else {
                        CategoriesView(items: $items)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .navigationTitle(isSearchActive ? "" : "Explore")
        }
    }
}

struct SearchResultsView: View {
    @Binding var selectedTab: String
    @Binding var isLoading: Bool
    @Binding var errorMessage: String?
    @Binding var postSearchResults: [PostResult]
    @Binding var userSearchResults: [UserResult]
    
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
            ForEach(userSearchResults) { user in
                HStack {
                    Circle()
                        .fill(Color(.systemGray))
                        .frame(width: 30, height: 30)
                    
                    Text(user.username)
                        .padding(5)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .cornerRadius(10)
                }
            }
        } else {
            Text("No results found.")
                .padding()
        }
    }
}

struct CategoriesView: View {
    @Binding var items: [String]
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
                    ForEach(items.indices, id: \.self) { index in
                        if index < 2 {
                            // Large Categoryies
                            Section {
                                
                            } header: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color(.systemGray5))
                                        .frame(height: 100)
                                    Text(items[index])
                                        .foregroundColor(Color(.black))
                                        .font(.headline)
                                }
                            }
                        } else {
                            // Small Categories
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(.systemGray5))
                                    .frame(height: 100)
                                Text(items[index])
                                    .foregroundColor(.black)
                                    .font(.headline)
                            }
                        }
                    }
                }
                .padding(.horizontal)
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
                                    .frame(width: 30, height: 30)
                                
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
