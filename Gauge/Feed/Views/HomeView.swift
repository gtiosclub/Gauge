//
//  HomeView.swift
//  Gauge
//
//  Created by Austin Huguenard on 2/6/25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var userVM: UserFirebase
    @State var showComments: Bool = false
    
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
                
            }
            .sheet(isPresented: $showComments) {
                CommentsView(
                    comments: [
                        Comment(
                            commentType: .text,
                            userId: "Lv72Qz7Qc4TC2vDeE94q",
                            date: Date(),
                            commentId: "",
                            likes: [],
                            dislikes: [],
                            content: "Love seeing all the amazing things happening here! Keep up the great work, everyone. 💯✨ #Inspiration #Community. Love seeing all the amazing things happening here! Keep up the great work, everyone. 💯✨ #Inspiration #Community."
                        ),
                        Comment(
                            commentType: .text,
                            userId: "Lv72Qz7Qc4TC2vDeE94q",
                            date: Date(),
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
