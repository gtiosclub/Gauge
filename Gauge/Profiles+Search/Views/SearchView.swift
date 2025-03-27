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
    @State private var searchResults: [PostResult] = []
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    @State private var showResults: Bool = false
    @State private var isSearchActive: Bool = false
    @State private var selectedCategory: Category? = nil

    @State var items = Array(Category.allCases.shuffled().prefix(through: min(7, Category.allCases.count - 1)))
    
    var body: some View {
        NavigationStack {
            VStack {
                // Search Bar (unchanged)
                HStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Color(.systemGray))
                        
                        TextField("Search", text: $searchText)
                            .foregroundColor(Color(.black))
                            .focused($isSearchFieldFocused)
                            .submitLabel(.search)
                            .onChange(of: isSearchFieldFocused) { focused in
                                if focused {
                                    isSearchActive = true
                                    selectedCategory = nil
                                }
                            }
                            .onSubmit {
                                if !searchText.isEmpty {
                                    performSearch()
                                }
                            }

                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                                showResults = false
                                searchResults = []
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
                            searchResults = []
                            showResults = false
                            selectedCategory = nil
                        }
                        .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal, 4)
                .padding(.top, 1)
                .padding(.bottom, 10)
                
                Group {
                    if let category = selectedCategory {
                        categoryPostsView(category: category)
                    } else if isSearchActive {
                        if showResults {
                            searchResultsView()
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
                            searchResults: $searchResults,
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
        } else if !searchResults.isEmpty {
            List {
                ForEach(searchResults) { result in
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
    
    @ViewBuilder
    private func searchResultsView() -> some View {
        if isLoading {
            ProgressView("Searching...")
                .padding()
        } else if let errorMessage = errorMessage {
            Text(errorMessage)
                .foregroundStyle(.red)
                .padding()
        } else if !searchResults.isEmpty {
            List {
                ForEach(searchResults) { result in
                    PostResultRow(result: result)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 6, leading: 8, bottom: 6, trailing: 8))
                }
            }
            .listStyle(.plain)
        } else {
            Text("No results found.")
                .padding()
        }
    }
    
    private func performSearch() {
        isLoading = true
        showResults = true
        Task {
            do {
                let results = try await searchVM.searchPosts(for: searchText)
                await MainActor.run {
                    searchResults = results
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
                    searchResults = results
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

struct CategoriesView: View {
    @Binding var categories: [Category]
    @Binding var selectedCategory: Category?
    @Binding var isLoading: Bool
    @Binding var searchResults: [PostResult]
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
                    searchResults = results
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

#Preview {
    SearchView()
}
