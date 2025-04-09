//
//  CategorySelectionView.swift
//  Gauge
//
//  Created by Sahil Ravani on 4/1/25.
//

import SwiftUI

struct CategorySelectionView: View {
    @EnvironmentObject var authVM: AuthenticationVM
    @State private var selectedCategories: Set<String> = []
    @State private var searchText: String = ""
    
    let allCategories = ["Music", "Travel", "Fitness", "Art", "Tech", "Gaming", "Books", "Movies"]
    
    var filteredCategories: [String] {
        if searchText.isEmpty {
            return allCategories
        } else {
            return allCategories.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            ProgressBar(progress: 5, steps: 6)
            Spacer().frame(height: 40)
            
            HStack(spacing: 8) {
                ForEach(0..<4) { index in
                    Capsule()
                        .fill(index < 3 ? Color.blue : Color.gray.opacity(0.3))
                        .frame(height: 4)
                }
            }
            .padding(.horizontal)
            
            HStack {
                Button(action: {
                    authVM.onboardingState = .bio
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Text("About You")
                    .font(.headline)
                    .bold()
                
                Spacer()
                
                Image(systemName: "chevron.left")
                    .opacity(0)
            }
            .padding(.horizontal)
            
            Text(selectedCategories.count < 3
                 ? "Choose \(3 - selectedCategories.count) more categories."
                 : "You can choose more categories if you like.")
            .font(.headline)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            
            CategorySearchBar(text: $searchText)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 140))], spacing: 16) {
                ForEach(filteredCategories, id: \.self) { category in
                    CategoryCard(
                        category: category,
                        isSelected: selectedCategories.contains(category)
                    ) {
                        toggleCategorySelection(category)
                    }
                    .frame(height: 120)
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            Button(action: {
                authVM.tempUserData.selectedCategories = selectedCategories
                authVM.onboardingState = .attributes
            }) {
                Text("Next")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .disabled(selectedCategories.count < 3)
            .padding(.horizontal)
            .padding(.bottom)

        }
        .onAppear {
            selectedCategories = authVM.tempUserData.selectedCategories
        }
        .padding(.horizontal)
        .padding(.bottom)
    }

    private func toggleCategorySelection(_ category: String) {
        if selectedCategories.contains(category) {
            selectedCategories.remove(category)
        } else {
            selectedCategories.insert(category)
        }
    }
}

struct CategoryCard: View {
    let category: String
    let isSelected: Bool
    let toggleSelection: () -> Void

    var body: some View {
        Text(category)
            .font(.headline)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
            .background(isSelected ? Color.white : Color.gray.opacity(0.2))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.black : Color.clear, lineWidth: 2)
            )
            .cornerRadius(12)
            .onTapGesture {
                toggleSelection()
            }
    }
}

struct CategorySearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("Search", text: $text)
                .foregroundColor(.primary)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

#Preview {
    CategorySelectionView()
}
