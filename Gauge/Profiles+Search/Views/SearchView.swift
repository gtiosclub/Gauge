//
//  SearchView.swift
//  Gauge
//
//  Created by Anthony Le on 2/25/25.
//

import SwiftUI

struct SearchView: View {
    @EnvironmentObject var userFirebase: UserFirebase
    @StateObject private var searchVM = SearchViewModel()
    @State private var searchText: String = ""
    @FocusState private var isSearchFieldFocused: Bool
    @State private var selectedTab: String = "Topics"
    @State private var searchResults: [PostResult] = []
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    @State private var showResults: Bool = false
    @State private var isSearchActive: Bool = false
    @State var items = Array(Category.allCategoryStrings.shuffled().prefix(through: 19))

    // userFirebase.user.id
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
                            .onChange(of: isSearchFieldFocused) {
                                print("focus")
                                if isSearchFieldFocused {
                                    isSearchActive = true
                                    Task {
                                        await searchVM.lastFiveSearches(
                                            userID: "user123",
                                            isProfileSearch: selectedTab != "Topics"
                                        )
                                    }
                                }
                            }
                            .onSubmit {
                                if !searchText.isEmpty {
                                    isLoading = true
                                    showResults = true
                                    performSearch()
                                }
                            }

                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                                showResults = false
                                searchResults = []
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
                        }
                        .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal, 4)
                .padding(.top, 1)
                .padding(.bottom, 10)

                AnyView(
                    Group {
                        if isSearchActive {
                            if showResults {
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
                            } else {
                                RecentSearchesView(
                                    isSearchFieldFocused: $isSearchFieldFocused,
                                    searchText: $searchText,
                                    selectedTab: $selectedTab,
                                    searchVM: searchVM,
                                )
                            }
                        } else {
                            CategoriesView(items: $items)
                        }
                    }
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .navigationTitle(isSearchActive ? "" : "Explore")
        }
    }

    // Extracted for clarity
    func performSearch() {
        Task {
            do {
                let results = try await searchVM.searchPosts(for: searchText)

                if selectedTab == "Topics" {
                    await MainActor.run {
                        searchVM.addRecentlySearchedPost(userId: "user123", search: searchText)
                    }
                } else {
                    await MainActor.run {
                        searchVM.addRecentlySearchedProfile(userId: "user123", search: searchText)
                    }
                }

                // Sync the real last 5 from Firestore
                await searchVM.lastFiveSearches(
                    userID: "user123",
                    isProfileSearch: selectedTab != "Topics"
                )

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
    @ObservedObject var searchVM: SearchViewModel  // link SearchViewModel
    @EnvironmentObject var userFirebase: UserFirebase
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Recent")
                .font(.headline)
                .padding(.leading)

            
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    if selectedTab == "Topics" {
                        ForEach(searchVM.recentFiveTopics, id: \.self) { topic in
                            HStack {
                                Image(systemName: "number")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.black)
                                    .padding(8)
                                    .background(Color(.systemGray5))
                                    .clipShape(Circle())

                                Text(topic) // ✅ Show the actual search term

                                Spacer()

                                Button(action: {
                                    searchVM.deleteRecentlySearched(
                                        userId: "user123",
                                        searchTerm: topic,
                                        isProfileSearch: false
                                    )
                                }) {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 12, weight: .regular))
                                        .foregroundColor(Color(.systemGray))
                                        .padding()
                                }
                            }
                        }

                    } else {
                        ForEach(searchVM.recentFiveProfiles, id: \.self) { profile in
                            HStack {
                                Circle()
                                    .fill(Color(.systemGray))
                                    .frame(width: 30, height: 30)

                                Text(profile)

                                Spacer()

                                Button(action: {
                                    searchVM.deleteRecentlySearched(
                                        userId: "user123",
                                        searchTerm: profile,
                                        isProfileSearch: true
                                    )
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
            .onAppear {
                   Task {
                       await searchVM.lastFiveSearches(
                           userID: "user123",
                           isProfileSearch: selectedTab != "Topics"
                       )
                   }
               }
               .onChange(of: selectedTab) { newTab in
                   Task {
                       await searchVM.lastFiveSearches(
                           userID: "user123",
                           isProfileSearch: newTab != "Topics"
                       )
                   }
               }
            // added ^^^^^
            
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
        .environmentObject(UserFirebase())     // Fixes build crash
        .environmentObject(PostFirebase())     // optional for testing**
}
