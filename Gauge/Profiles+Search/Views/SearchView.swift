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
    @State var items = Array(1...50).map { "Category \($0)" }
    
    
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
                    CategoriesView(items: $items)
                }
            }
            .navigationTitle(isSearchFieldFocused ? "" : "Explore")
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

struct RecentSearchesView: View {
    @FocusState.Binding var isSearchFieldFocused: Bool
    @Binding var searchText: String
    
    @State private var recentSearches = ["topic", "topic", "topic", "topic", "topic"]
    @State private var recentUsers = ["username", "username", "username", "username", "username"]
    let tabs = ["Topics", "Users"]
    @State private var selectedTab: String = "Topics"

    var body: some View {
        VStack(alignment: .leading) {
            Text("Recent")
                .font(.headline)
                .padding(.leading)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    if (selectedTab == "Topics") {
                        ForEach(Array(recentSearches.enumerated()), id: \.element) { index, search in
                            HStack{
                                HStack {
                                    Image(systemName: "number")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.black)
                                        .padding(8)
                                        .background(Color(.systemGray5))
                                        .clipShape(Circle())
                                    
                                    Text(search)
                                        .padding(5)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color.white)
                                        .cornerRadius(10)
                                }
                                
                                Button(action: {
                                    recentSearches.remove(at: index)
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
                            HStack{
                                HStack {
                                    Circle()
                                        .fill(Color(.systemGray))
                                        .frame(width: 30, height: 30)
                                    Text(user)
                                        .padding(5)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color.white)
                                        .cornerRadius(10)
                                }
                                
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
        }
        
        Picker(selection: $selectedTab, label: Text("")) {
            ForEach(tabs, id: \.self) { tab in
                Text(tab).tag(tab)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .frame(width: 300)
        .padding()
    }
}

#Preview {
    SearchView()
}
