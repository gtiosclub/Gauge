//
//  SearchView.swift
//  Gauge
//
//  Created by Anthony Le on 2/25/25.
//

import SwiftUI

struct SearchView: View {
    @State private var searchText: String = ""
    @FocusState private var isSearchFieldFocused: Bool
    let items = Array(1...50).map { "Category \($0)" }
    
    // Define the grid columns
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
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
                            .onTapGesture {
                                isSearchFieldFocused = true
                            }
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    isSearchFieldFocused = true
                                }
                            }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 5)
                    .background(Color(.systemGray5))
                    .cornerRadius(12)
                    
                    if isSearchFieldFocused {
                        Button("Cancel") {
                            isSearchFieldFocused = false
                            searchText = ""
                        }
                        .foregroundColor(.blue)
                        .padding(.leading, 1)
                        .transition(.move(edge: .trailing))
                        .animation(.easeInOut, value: isSearchFieldFocused)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 1)
                .padding(.bottom, 10)
                
                if isSearchFieldFocused {
                    RecentSearchesView(isSearchFieldFocused: $isSearchFieldFocused, searchText: $searchText)
                } else {
                    // Categories
                    Text("Categories")
                        .font(.headline)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 10) {
                            ForEach(items.indices, id: \.self) { index in
                                if index < 2 {
                                    // Large Categories
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
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle(isSearchFieldFocused ? "" : "Explore")
        }
    }
}

struct RecentSearchesView: View {
    @FocusState.Binding var isSearchFieldFocused: Bool
    @Binding var searchText: String
    let recentSearches = ["Ha", "UIKit", "iOS 17", "Xcode", "Instagram Clone"]

    var body: some View {
        VStack(alignment: .leading) {
            Text("Recent Searches")
                .font(.headline)
                .padding(.leading)
            
            List(recentSearches, id: \.self) { search in
                Button(action: {
                    searchText = search
                    isSearchFieldFocused = false
                }) {
                    Text(search)
                        .foregroundColor(.black)
                        .padding(.vertical, 5)
                }
            }
            .listStyle(PlainListStyle())
        }
    }
}

#Preview {
    SearchView()
}
