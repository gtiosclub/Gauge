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
    @State var selectedCategories: [Category] = []
    
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
                    SelectCategories(
                        selectedCategories: $selectedCategories,
                        question: "Which channel is better?",
                        responseOptions: ["National Geographic", "Animal Planet"]
                    )
                }
                
                NavigationLink("Feed View") {
                    FeedView()
                }
            }
            .sheet(isPresented: $showComments) {
                CommentsView(
                    comments: [
                        Comment(
                            commentType: .text,
                            postId: "555555555",
                            userId: "Lv72Qz7Qc4TC2vDeE94q",
                            date: Calendar.current.date(byAdding: .hour, value: -5, to: Date())!,
                            commentId: "",
                            likes: [],
                            dislikes: [],
                            content: "Love seeing all the amazing things happening here! Keep up the great work, everyone. 💯✨ #Inspiration #Community. Love seeing all the amazing things happening here! Keep up the great work, everyone. 💯✨ #Inspiration #Community."
                        ),
                        Comment(
                            commentType: .text,
                            postId: "555555555",
                            userId: "Lv72Qz7Qc4TC2vDeE94q",
                            date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!,
                            commentId: "",
                            likes: [],
                            dislikes: [],
                            content: "Love seeing all the amazing things happening here! Keep up the great work, everyone. 💯✨ #Inspiration #Community. Love seeing all the amazing things happening here! Keep up the great work, everyone. 💯✨ #Inspiration #Community."
                        )
                    ]
                )
                .presentationDetents([.medium])
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(UserFirebase())
        .environmentObject(PostFirebase())
}
