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
    @State var suggestedCategories: [Category] = []
    @Binding var selectedCategories: [Category]
    @Binding var stepCompleted: Bool
    
    let question: String
    let responseOptions: [String]
    
    var filteredCategories: [String] {
        categoryInput.isEmpty ? [] : Category.allCategoryStrings.filter { $0.localizedCaseInsensitiveContains(categoryInput)
            && !selectedCategories.contains(Category.stringToCategory($0)!)
            && !suggestedCategories.contains(Category.stringToCategory($0)!)
        }
    }
    
    func getSuggestedCategories() {
        postVM.suggestPostCategories(
            question: self.question,
            responseOptions: self.responseOptions
        ) { suggestedCategories in
            for category in suggestedCategories {
                if !selectedCategories.contains(category) {
                    self.suggestedCategories.append(category)
                }
            }
        }
        
        stepCompleted = selectedCategories.count > 0
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 10) {
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
                
                ScrollView {
                    FlowLayout(verticalSpacing: 5, horizontalSpacing: 5) {
                        ForEach(selectedCategories, id: \.self) { category in
                            Button(category.rawValue) {
                                withAnimation {
                                    selectedCategories = selectedCategories.filter { $0 != category}
                                }
                                stepCompleted = selectedCategories.count > 0
                            }
                            .padding(10)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .background(Color(.systemGray6))
                            .foregroundColor(.black)
                            .cornerRadius(20)
                            .fixedSize()
                        }
                    }
                }
                
                if (!suggestedCategories.isEmpty) {
                    VStack {
                        HStack {
                            Text("Suggested")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Spacer()
                        }
                        
                        FlowLayout(verticalSpacing: 5, horizontalSpacing: 5) {
                            ForEach(suggestedCategories, id: \.self) { category in
                                Button(category.rawValue) {
                                    withAnimation {
                                        if (!selectedCategories.contains(category)) {
                                            selectedCategories.append(category)
                                        }
                                        suggestedCategories = suggestedCategories.filter { $0 != category }
                                        
                                        stepCompleted = selectedCategories.count > 0
                                    }
                                }
                                .padding(10)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .background(Color(.systemGray6))
                                .foregroundColor(.black)
                                .cornerRadius(20)
                                .fixedSize()
                            }
                        }
                    }
                }
                
                Spacer()
            }
            
            if isSearching {
                VStack(alignment: .leading, spacing: 10) {
                    List(filteredCategories, id: \.self) { category in
                        Button(category) {
                            withAnimation {
                                if (!selectedCategories.contains(Category.stringToCategory(category)!)) {
                                    selectedCategories.append(Category.stringToCategory(category)!)
                                }
                                isSearching = false
                                stepCompleted = selectedCategories.count > 0
                            }
                        }
                        .padding(.vertical, 5)
                    }
                    .listStyle(PlainListStyle())
                    .frame(height: min(CGFloat(filteredCategories.count) * 44, 130))
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .offset(y: 50)
                    
                    Spacer()
                }
                .padding(.top, 3)
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
        .padding(.horizontal, 20)
        .onAppear(perform: getSuggestedCategories)
    }
}

#Preview {
//    @Previewable @State var selectedCategories: [Category] = []
//    SelectCategories(
//        selectedCategories: $selectedCategories,
//        question: "Which channel is better?",
//        responseOptions: ["National Geographic", "Animal Planet"]
//    )
//        .environmentObject(PostFirebase())
}
