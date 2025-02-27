//
//  CommentsView.swift
//  Gauge
//
//  Created by Krish Prasad on 2/27/25.
//

import SwiftUI

struct CommentsView: View {
    let comments: [Comment]
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(comments, id: \.self) { comment in
                    CommentView(comment: comment)
                }
            }
        }
    }
}

#Preview {
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
    .environmentObject(UserFirebase())
}
