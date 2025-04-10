//
//  CategoriesView.swift
//  Gauge
//
//  Created by Datta Kansal on 4/10/25.
//

import SwiftUI

struct CategoriesView: View {
    @EnvironmentObject var userVM: UserFirebase
    @State private var categories: [Category] = []
    @Binding var selectedCategory: Category?
    @Binding var isLoading: Bool
    @Binding var postSearchResults: [PostResult]
    @Binding var errorMessage: String?
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Categories")
                    .font(.headline)
                    .bold()
                    .padding(.horizontal)

                if categories.count >= 2 {
                    VStack(spacing: 10) {
                        CategoryItemView(
                            category: categories[0],
                            isLarge: true,
                            onCategoryTap: { category in
                                selectedCategory = category
                            }
                        )
                        CategoryItemView(
                            category: categories[1],
                            isLarge: true,
                            onCategoryTap: { category in
                                selectedCategory = category
                            }
                        )
                    }
                    .padding(.horizontal)
                }
                
                let smallCategories = Array(categories.dropFirst(2))
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(smallCategories, id: \.self) { category in
                        CategoryItemView(
                            category: category,
                            isLarge: false,
                            onCategoryTap: { category in
                                selectedCategory = category
                            }
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
        }
        .onAppear {
            populateCategories()
        }
    }
    
    
    private func populateCategories() {
        let userCategoryStrings = userVM.user.myCategories
        
        let userCategories: [Category] = userCategoryStrings.compactMap { Category.stringToCategory($0) }
        
        if userCategories.isEmpty {
            categories = Array(Category.allCases.shuffled().prefix(20))
        } else {
            let topUserCategories = Array(userCategories.prefix(20))
            if topUserCategories.count < 20 {
                let needed = 20 - topUserCategories.count
                let remainingCategories = Category.allCases.filter { category in
                    !topUserCategories.contains(where: { $0.rawValue == category.rawValue })
                }.shuffled()
                let additionalCategories = Array(remainingCategories.prefix(needed))
                categories = topUserCategories + additionalCategories
            } else {
                categories = topUserCategories
            }
        }
    }
    
    private func selectCategory(_ category: Category) {
        selectedCategory = category
        loadCategoryPosts(category: category)
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
