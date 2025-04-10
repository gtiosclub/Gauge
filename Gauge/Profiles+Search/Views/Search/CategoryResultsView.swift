//
//  CategoryResultsView.swift
//  Gauge
//
//  Created by Datta Kansal on 4/10/25.
//
import SwiftUI

struct CategoryResultsView: View {
    let category: Category
    var onDismiss: (() -> Void)? = nil  // Callback to clear parent's state
    
    @State private var postSearchResults: [PostResult] = []
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
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
        .navigationTitle(category.rawValue)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                    onDismiss?()
                } label: {
                    Image(systemName: "arrow.left")
                        .foregroundColor(.blue)
                }
            }
        }
        .onAppear {
            loadCategoryPosts(category: category)
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
