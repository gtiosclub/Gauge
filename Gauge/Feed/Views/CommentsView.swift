//
//  CommentsView.swift
//  Gauge
//
//  Created by Krish Prasad on 2/27/25.
//

import SwiftUI

struct CommentsView: View {
    var comments: [Comment]
    @State private var sortedComments: [Comment] = []
    
    var body: some View {
        ScrollView {
            if comments.isEmpty {
                Text("No Comments Yet!")
                Button("Be the first") {
                    
                }
            } else {
                LazyVStack {
                    ForEach(sortedComments, id: \.self) { comment in
                        CommentView(comment: comment)
                    }
                }
            }
        }
        .onAppear {
            sortedComments = comments.sorted {
                ($0.likes.count - $0.dislikes.count) > ($1.likes.count - $1.dislikes.count)
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
                content: "Love seeing all the amazing things happening here! Keep up the great work, everyone. 💯✨ #Inspiration #Communityee. Love seeing all the amazing things happening here! Keep up the great work, everyone. 💯✨ #Inspiration #Community."
            ),
            Comment(
                commentType: .text,
                userId: "Lv72Qz7Qc4TC2vDeE94q",
                date: Date(),
                commentId: "",
                likes: [],
                dislikes: [],
                content: "Love seeing all the amazing things happening here! Keep up the great work, everyone. 💯✨ #Inspiration #Communitwwy. Love seeing all the amazing things happening here! Keep up the great work, everyone. 💯✨ #Inspiration #Community."
            )
        ]
    )
    .environmentObject(UserFirebase())
}
