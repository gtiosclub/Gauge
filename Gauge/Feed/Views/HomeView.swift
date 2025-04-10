//
//  HomeView.swift
//  Gauge
//
//  Created by Austin Huguenard on 2/6/25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var userVM: UserFirebase
    @EnvironmentObject var postVM: PostFirebase
    @State var showComments: Bool = false
    @State var showPostCreation: Bool = false
    @State var selectedCategories: [Category] = []
    
    @State var modalSize: CGFloat = 380
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Hello, \(userVM.user.username)!")
                
                NavigationLink("To Testing Screen") {
                    FirebaseTesting()
                }
                
                Button("Show Comments View") {
                    showComments = true
                }
                
                NavigationLink("Select Categories Screen") {
//                    SelectCategories(
//                        selectedCategories: $selectedCategories,
//                        question: "Which channel is better?",
//                        responseOptions: ["National Geographic", "Animal Planet"]
//                    )
                }
                
                Button("Post creation view") {
                    showPostCreation = true
                }
                
                NavigationLink("Feed View") {
                    FeedView()
                }
                NavigationLink("Add Comment view"){
                    AddCommentView()
                }
            }
            .sheet(isPresented: $showPostCreation) {
                PostCreationView(modalSize: $modalSize, showCreatePost: $showPostCreation)
                    .presentationDetents([.height(modalSize)])
                    .presentationBackground(.clear)
                    .background(
                        RoundedRectangle(cornerRadius: 36, style: .continuous)
                            .fill(Color.white)
                    )
                    .padding(.horizontal, 10)
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(UserFirebase())
        .environmentObject(PostFirebase())
}
