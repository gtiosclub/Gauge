//
//  SelectCategories.swift
//  Gauge
//
//  Created by Krish Prasad on 2/27/25.
//

import SwiftUI

struct SelectCategories: View {
    @EnvironmentObject var postVM: PostFirebase
    @State var categoryInput: String = ""
    @State var isSearching: Bool = false
    @State var suggestedCategories: [Category] = [Category.sports(.collegeFootball), Category.arts(.music)]
    @State var selectedCategories: [Category] = [Category.sports(.nfl), Category.arts(.artwork)]
    
    var filteredCategories: [String] {
        categoryInput.isEmpty ? [] : Category.allCategoryStrings.filter { $0.localizedCaseInsensitiveContains(categoryInput) }
    }
    
    func getSuggestedCategories() {
//        postVM.suggestPostCategories(
//            question: "Which channel is better?",
//            responseOptions: ["National Geographic", "Animal Planet"]
//        ) { suggestedCategories in
//            self.suggestedCategories = suggestedCategories
//        }
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 25) {
                HStack {
                    Text("Select categories")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Spacer()
                }
                
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search Categories",
                              text: $categoryInput,
                              onEditingChanged: { isEditing in
                        withAnimation {
                            isSearching = isEditing || !categoryInput.isEmpty
                        }
                    }
                    )
                    .foregroundColor(.primary)
                    .onChange(of: categoryInput) { _ in
                        withAnimation {
                            isSearching = !categoryInput.isEmpty
                        }
                    }
                }
                .padding(10)
                .background(Color(.systemGray5))
                .cornerRadius(20)
                
                HStack {
                    ForEach(selectedCategories, id: \.self) { category in
                        Button(category.rawValue) {
                            withAnimation {
                                selectedCategories = selectedCategories.filter { $0 != category}
                            }
                        }
                        .padding(10)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .background(Color(.systemGray6))
                        .foregroundColor(.black)
                        .cornerRadius(20)
                    }
                    
                    Spacer()
                }
                
                if (!suggestedCategories.isEmpty) {
                    VStack {
                        HStack {
                            Text("Suggested")
                                .font(.title3)
                                .fontWeight(.bold)
                            
                            Spacer()
                        }
                        
                        HStack {
                            ForEach(suggestedCategories, id: \.self) { category in
                                Button(category.rawValue) {
                                    withAnimation {
                                        selectedCategories.append(category)
                                        suggestedCategories = suggestedCategories.filter { $0 != category }
                                    }
                                }
                                .padding(10)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .background(Color(.systemGray6))
                                .foregroundColor(.black)
                                .cornerRadius(20)
                            }
                            
                            Spacer()
                        }
                    }
                }
                
            }
            
            if isSearching {
                VStack(alignment: .leading, spacing: 0) {
                    List(filteredCategories, id: \.self) { category in
                        Button(category) {
                            selectedCategories.append(Category.stringToCategory(category)!)
                            withAnimation {
                                isSearching = false
                            }
                        }
                        .padding(.vertical, 5)
                    }
                    .listStyle(PlainListStyle())
                    .frame(height: min(CGFloat(filteredCategories.count) * 44, 170))
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .offset(y: 50)
                    
                    Spacer()
                }
                .padding(.top, 310)
                .zIndex(2)
            
                //Background to dismiss searching
                Color.black.opacity(0.001)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation {
                            isSearching = false
                        }
                    }
            }
        }
        .onAppear(perform: getSuggestedCategories)
    }
}

#Preview {
    SelectCategories()
        .environmentObject(PostFirebase())
}
