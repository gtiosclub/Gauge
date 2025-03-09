//
//  VectorSearchTestView.swift
//  Gauge
//
//  Created by Datta Kansal on 3/3/25.
//

import SwiftUI

struct VectorSearchTestView: View {
    @State private var searchQuery = ""
    @State private var resultIds: [String] = []
    @State private var isSearching = false
    @State private var errorMessage: String?
    
    private let searchVM = SearchViewModel()
    
    var body: some View {
        VStack {
            Text("Vector Search Test")
                .font(.title)
                .padding()
            
            HStack {
                TextField("Enter your question", text: $searchQuery)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                Button(action: performSearch) {
                    Text("Search")
                        .padding(.horizontal)
                }
            }
            .padding()
            
            if isSearching {
                ProgressView("Searching...")
                    .padding()
            } else if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            } else {
                VStack(alignment: .leading) {
                    Text("Results: \(resultIds.count) matches")
                        .font(.headline)
                        .padding()
                    
                    List {
                        ForEach(resultIds, id: \.self) { id in
                            Text("Post ID: \(id)")
                                .padding(.vertical, 4)
                        }
                    }
                }
            }
        }
    }
    
    private func performSearch() {
        guard !searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        isSearching = true
        errorMessage = nil
        
        Task {
            do {
                let ids = try await searchVM.searchSimilarQuestions(query: searchQuery)
                
                await MainActor.run {
                    resultIds = ids
                    isSearching = false
                }
            } catch {
                await MainActor.run {
                    resultIds = []
                    errorMessage = "Search failed: \(error.localizedDescription)"
                    isSearching = false
                }
            }
        }
    }
}

#Preview {
    VectorSearchTestView()
}
