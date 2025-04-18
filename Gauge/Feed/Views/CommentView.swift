//
//  CommentView.swift
//  Gauge
//
//  Created by Krish Prasad on 2/22/25.
//

import SwiftUI

struct CommentView: View {
    @EnvironmentObject private var userVM: UserFirebase
    @EnvironmentObject private var postVM: PostFirebase
    @Environment(\.modelContext) private var modelContext

    let comment: Comment
    let post: any Post

    @State private var userStatus = "none"

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack() {
                ProfileUsernameDateView(dateTime: comment.date, userId: comment.userId)
                    .padding(.trailing, 10)
                    .fixedSize(horizontal: true, vertical: true)
                
                Spacer(minLength: 4)
                    .frame(height: 0.5)
                        .background(Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 0)
                                .stroke(Color.lightGray, lineWidth: 0.5)
                        )
                
                let (isFirstLabel, responseOption) = findUserResponse(post: post, userId: comment.userId)
                let color = (post as? SliderPost) != nil ? SliderResultView.colorForIndex((Int(responseOption) ?? 1) - 1, (Int(responseOption) ?? 1) - 1) : (responseOption == (post as! BinaryPost).responseOption1 ? Color.darkRed : Color.darkGreen)
                
                Text(responseOption)
                    .font(.system(size: 14))
                    .foregroundColor(color)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(color.opacity(0.2))
                    )
                    .padding(.leading, 10)
                    .minimumScaleFactor(0.8)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            ExpandableText(comment.content)
                .foregroundColor(Color(white: 0.2))
                .multilineTextAlignment(.leading)

            HStack(spacing: 10) {
                Spacer()
                
                Button {
                    toggleLike()
                } label: {
                    Image(systemName: "arrowtriangle.up.fill")
                        .resizable()
                        .frame(width: 13, height: 13)
                        .foregroundColor(userStatus == "liked" ? .green : Color(white: 0.5))
                }

                Text("\(comment.likes.count - comment.dislikes.count)")
                    .foregroundColor(userStatus == "liked" ? .green : (userStatus == "disliked") ? .red : Color(white: 0.5))

                Button {
                    toggleDislike()
                } label: {
                    Image(systemName: "arrowtriangle.down.fill")
                        .resizable()
                        .frame(width: 13, height: 13)
                        .foregroundColor(userStatus == "disliked" ? .red : Color(white: 0.5))
                }
            }
            .frame(alignment: .trailing)
        }
        .padding(.horizontal)
        .padding(.vertical, 5)
        .task {
            if comment.likes.contains(userVM.user.id) {
                userStatus = "liked"
            } else if comment.dislikes.contains(userVM.user.id) {
                userStatus = "disliked"
            }
        }
    }

    private func toggleLike() {
        if userStatus != "liked" {
            postVM.likeComment(postId: comment.postId, commentId: comment.commentId, userId: userVM.user.id)
            UserResponsesManager.addCategoriesToUserResponses(modelContext: modelContext, categories: post.categories.map{$0.rawValue})
            UserResponsesManager.addTopicsToUserResponses(modelContext: modelContext, topics: post.topics)
            
            if userStatus == "disliked" {
                postVM.removeDislike(postId: comment.postId, commentId: comment.commentId, userId: userVM.user.id)
            }
            userStatus = "liked"
        } else {
            postVM.removeLike(postId: comment.postId, commentId: comment.commentId, userId: userVM.user.id)
            UserResponsesManager.removeCategoriesFromUserResponses(modelContext: modelContext, categories: post.categories.map{$0.rawValue})
            UserResponsesManager.removeTopicsFromUserResponses(modelContext: modelContext, topics: post.topics)

            userStatus = "none"
        }
    }

    private func toggleDislike() {
        if userStatus != "disliked" {
            postVM.dislikeComment(postId: comment.postId, commentId: comment.commentId, userId: userVM.user.id)
            
            if userStatus == "liked" {
                postVM.removeLike(postId: comment.postId, commentId: comment.commentId, userId: userVM.user.id)
            }
            
            userStatus = "disliked"
            UserResponsesManager.addCategoriesToUserResponses(modelContext: modelContext, categories: post.categories.map{$0.rawValue})
            UserResponsesManager.addTopicsToUserResponses(modelContext: modelContext, topics: post.topics)
        } else {
            postVM.removeDislike(postId: comment.postId, commentId: comment.commentId, userId: userVM.user.id)
            userStatus = "none"
            UserResponsesManager.removeCategoriesFromUserResponses(modelContext: modelContext, categories: post.categories.map{$0.rawValue})
            UserResponsesManager.removeTopicsFromUserResponses(modelContext: modelContext, topics: post.topics)
        }
    }
}

func findUserResponse(post: any Post, userId: String) -> (Bool, String) {
    for response in post.responses {
        if response.userId == userId {
            if let binaryPost = post as? BinaryPost {
                return (binaryPost.responseOption1 == response.responseOption, response.responseOption)
            } else if let sliderPost = post as? SliderPost {
                return ((Int(response.responseOption) ?? 1) < 3, String((Int(response.responseOption) ?? 1)))
            }
        }
    }
    return (false, "")
}

//#Preview {
//    CommentView(comment: Comment(
//        commentType: .text,
//        postId: "81915E51-E823-4D73-B7C3-201EF39DD675",
//        userId: "2lCFmL9FRjhY1v1NMogD5H6YuMV2",
//        date: Calendar.current.date(byAdding: .hour, value: -6, to: Date())!,
//        commentId: "WiIaeW7EIlTr7Mq97PkI",
//        likes: ["2lCFmL9FRjhY1v1NMogD5H6YuMV2", "2lCFmL9FRjhY1v1NMogD5H6YuMV2"],
//        dislikes: ["2lCFmL9FRjhY1v1NMogD5H6YuMV2"],
//        content: "I might swerve, bend that corner, woah. I might swerve, bend that corner, woah. I might swerve, bend that corner, woah. I might swerve, bend that corner, woah."
//    ))
//    .environmentObject(UserFirebase())
//    .environmentObject(PostFirebase())
//}
