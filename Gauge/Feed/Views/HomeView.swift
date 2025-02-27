//
//  HomeView.swift
//  Gauge
//
//  Created by Austin Huguenard on 2/6/25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var userVM: UserFirebase
    
    var body: some View {
        VStack {
            Text("Hello, \(userVM.user.username)!")
            
            NavigationLink("To Testing Screen") {
                FirebaseTesting()
            }
            
            
            CommentView(comment: Comment(
                commentType: .text,
                userId: "Lv72Qz7Qc4TC2vDeE94q",
                date: Date(),
                commentId: "",
                likes: [],
                dislikes: [],
                content: "Love "
            ))
            CommentView(comment: Comment(
                commentType: .text,
                userId: "Lv72Qz7Qc4TC2vDeE94q",
                date: Date(),
                commentId: "",
                likes: [],
                dislikes: [],
                content: "Love seeing all the amazing things happening here! Keep up the great work, everyone. 💯✨ #Inspiration #Community. Love seeing all the amazing things happening here! Keep up the great work, everyone. 💯✨ #Inspiration #Community. "
            ))
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(UserFirebase())
}
