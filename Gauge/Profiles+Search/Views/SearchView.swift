//
//  SearchView.swift
//  Gauge
//
//  Created by Anthony Le on 2/25/25.
//

import SwiftUI

struct SearchView: View {
    @State private var searchText: String = ""
    let items = Array(1...50).map { "Category \($0)" }
    
    // Define the grid columns
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    var body: some View {
        NavigationView {
            VStack {
                // Search Bar
                HStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Search", text: $searchText)
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
                .background(Color(red: 0.4627, green: 0.8392, blue: 1.0))
                
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
                                Section {
                                    
                                } header: {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.red)
                                            .frame(height: 100)
                                        Text(items[index])
                                            .foregroundColor(.white)
                                            .font(.headline)
                                    }
                                }
                            } else {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.blue)
                                        .frame(height: 100)
                                    
                                    Text(items[index])
                                        .foregroundColor(.white)
                                        .font(.headline)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                
                
                
                
                
            }
            .navigationTitle("Explore")
        }
    }
}

#Preview {
    SearchView()
}
