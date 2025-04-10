//
//  CategoriesView.swift
//  Gauge
//
//  Created by Datta Kansal on 4/10/25.
//

import SwiftUI

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
