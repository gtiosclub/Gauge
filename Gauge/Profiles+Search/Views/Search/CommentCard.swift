//
//  CommentCard.swift
//  Gauge
//
//  Created by amber verma on 4/14/25.
//

import SwiftUI
import Firebase

struct CommentCard: View {
    @EnvironmentObject var userVM: UserFirebase
    @EnvironmentObject var postVM: PostFirebase
    @State var comment: Comment

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ProfileUsernameDateView(dateTime: comment.date, userId: comment.userId)
            
            // Content
            Text(comment.content)
                .font(.body)

            // Actions: Reply + Triangular Votes
            HStack {
                Text("Reply")
                    .foregroundColor(.gray)
                    .font(.subheadline)

                Spacer()

                HStack(spacing: 16) {
                    Button(action: {
                        toggleLike()
                    }) {
                        Text("▲ \(comment.likes.count)")
                            .foregroundColor(.gray)
                    }

                    Button(action: {
                        toggleDislike()
                    }) {
                        Text("▼ \(comment.dislikes.count)")
                            .foregroundColor(.gray)
                    }
                }
                .font(.subheadline)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
    }

    func toggleLike() {
        let userId = userVM.user.userId
        let db = Firestore.firestore()
        let ref = db.collection("POSTS")
            .document(comment.postId)
            .collection("COMMENTS")
            .document(comment.commentId)

        if comment.likes.contains(userId) {
            // Remove like
            comment.likes.removeAll { $0 == userId }
            ref.updateData(["likes": FieldValue.arrayRemove([userId])])
        } else {
            // Add like
            comment.likes.append(userId)
            ref.updateData([
                "likes": FieldValue.arrayUnion([userId]),
                "dislikes": FieldValue.arrayRemove([userId])
            ])
            comment.dislikes.removeAll { $0 == userId }
        }
    }

    func toggleDislike() {
        let userId = userVM.user.userId
        let db = Firestore.firestore()
        let ref = db.collection("POSTS")
            .document(comment.postId)
            .collection("COMMENTS")
            .document(comment.commentId)

        if comment.dislikes.contains(userId) {
            // Remove dislike
            comment.dislikes.removeAll { $0 == userId }
            ref.updateData(["dislikes": FieldValue.arrayRemove([userId])])
        } else {
            // Add dislike
            comment.dislikes.append(userId)
            ref.updateData([
                "dislikes": FieldValue.arrayUnion([userId]),
                "likes": FieldValue.arrayRemove([userId])
            ])
            comment.likes.removeAll { $0 == userId }
        }
    }
}
