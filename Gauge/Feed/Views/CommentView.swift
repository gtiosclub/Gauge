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
    let comment: Comment
    let profilePhotoSize: CGFloat = 25
    @State var userStatus = "none"    

    struct LabelledDivider: View {

        let label: String
        let horizontalPadding: CGFloat
        let color: Color

        init(label: String, horizontalPadding: CGFloat = 3, color: Color) {
            self.label = label
            self.horizontalPadding = horizontalPadding
            self.color = color
        }

        var body: some View {
            HStack {
                line
                ZStack {
                    Text(label)
                        .font(.system(size: 14))
                        .foregroundColor(Color.whiteGray)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(
                            Capsule(style: .continuous)
                                .fill(color.opacity(0.2))
                        )
                }
            }
        }

        var line: some View {
            VStack {
                Divider()
                    .background(Color.whiteGray)
            }
            .padding(horizontalPadding)
        }
    }
    

    var body: some View {
        VStack {
            Spacer()
            HStack {
                VStack {
                    HStack() {
                        ProfileUsernameDateView(dateTime: comment.date, userId: comment.userId)
                        
                        //TODO: Make label modular and use it to change color
                        LabelledDivider(label: "Yes", color: userStatus == "liked" ? .green : (userStatus == "disliked") ? .red : Color(white: 0.5))
                    }
                    .frame(alignment: .leading)
                    
                    HStack {
                        ExpandableText(comment.content)
                            .lineLimit(nil)
                            .frame(alignment: .topLeading)
                            .foregroundColor(Color(white: 0.2))
                    }
                    
                    HStack {
                        /// UI for the "Reply" button in Figma
                        // Image(systemName: "arrowshape.turn.up.left")
                        // Text("Reply")
                        
                        Button {
                            print("Like Button")
                            if userStatus != "liked" {
                                postVM.likeComment(postId: comment.postId, commentId: comment.commentId, userId: userVM.user.id)
                                userStatus = "liked"
                                likeCount = likeCount + 1
                            } else {
                                postVM.removeLike(postId: comment.postId, commentId: comment.commentId, userId: userVM.user.id)
                                userStatus = "none"
                                likeCount = likeCount - 1
                            }

                        } label: {
                            if userStatus == "liked" {
                                Image(systemName: "arrowtriangle.up.fill")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 13, height: 13)
                                    .foregroundColor(.green)
                            } else {
                                Image(systemName: "arrowtriangle.up")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 13, height: 13)
                                    .foregroundColor(Color(white: 0.5))
                            }
                        }
                        
                        Text("\(likeCount - dislikeCount)")
                            .foregroundColor(userStatus == "liked" ? .green : (userStatus == "disliked") ? .red : Color(white: 0.5))
                        
                        Button {
                            print("Dislike Button")
                            if userStatus != "disliked" {
                                postVM.dislikeComment(postId: comment.postId, commentId: comment.commentId, userId: userVM.user.id)
                                userStatus = "disliked"
                                dislikeCount = dislikeCount + 1

                            } else  {
                                postVM.removeDislike(postId: comment.postId, commentId: comment.commentId, userId: userVM.user.id)
                                userStatus = "none"
                                dislikeCount = dislikeCount - 1

                            }

                        } label: {
                            if userStatus == "disliked" {
                                Image(systemName: "arrowtriangle.down.fill")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 13, height: 13)
                                    .foregroundColor(.red)
                            } else {
                                Image(systemName: "arrowtriangle.down")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 13, height: 13)
                                    .foregroundColor(Color(white: 0.5))
                            }
                        }
                        
                    }
                    .frame(maxWidth: .infinity, alignment: .bottomTrailing)
                    
                }
                
                
//                VStack(spacing: 7) {
//                    Button(action: {
//                        if userStatus != "liked" {
//                            postVM.likeComment(postId: comment.postId, commentId: comment.commentId, userId: userVM.user.id)
//                            userStatus = "liked"
//                        } else {
//                            postVM.removeLike(postId: comment.postId, commentId: comment.commentId, userId: userVM.user.id)
//                            userStatus = "none"
//                        }
//
//                    }) {
//                        Image(systemName: "arrow.up")
//                            .resizable()
//                            .frame(width: 11, height: 13)
//                            .fontWeight(.semibold)
//                            .foregroundColor(userStatus == "liked" ? .blue : .black)
//                    }
//
//                    Text("\(comment.likes.count - comment.dislikes.count)")
//                        .font(.callout)
//
//                    Button(action: {
//                        if userStatus != "disliked" {
//                            postVM.dislikeComment(postId: comment.postId, commentId: comment.commentId, userId: userVM.user.id)
//                            userStatus = "disliked"
//                        } else  {
//                            postVM.removeDislike(postId: comment.postId, commentId: comment.commentId, userId: userVM.user.id)
//                            userStatus = "none"
//                        }
//                    }) {
//                        Image(systemName: "arrow.down")
//                            .resizable()
//                            .frame(width: 11, height: 13)
//                            .fontWeight(.semibold)
//                            .foregroundColor(userStatus == "disliked" ? .blue : .black)
//                    }
//                }
//                .foregroundColor(.black)
                
            }
            Spacer()
        }
        .padding(.horizontal, 15)
        .task {
            if comment.likes.contains(userVM.user.id) {
                userStatus = "liked"
            } else if comment.dislikes.contains(userVM.user.id) {
                userStatus = "disliked"
            }
        }
    }
}

#Preview {
    CommentView(comment: Comment(
        commentType: .text,
        postId: "81915E51-E823-4D73-B7C3-201EF39DD675",
        userId: "2lCFmL9FRjhY1v1NMogD5H6YuMV2",
        date: Calendar.current.date(byAdding: .hour, value: -6, to: Date())!,
        commentId: "WiIaeW7EIlTr7Mq97PkI",
        likes: ["2lCFmL9FRjhY1v1NMogD5H6YuMV2", "2lCFmL9FRjhY1v1NMogD5H6YuMV2"],
        dislikes: ["2lCFmL9FRjhY1v1NMogD5H6YuMV2"],
        content: "I might swerve, bend that corner, woah. I might swerve, bend that corner, woah. I might swerve, bend that corner, woah. I might swerve, bend that corner, woah."
    ), responseOption1: "Yes", userResponseOption: "Yes")
    .environmentObject(UserFirebase())
    .environmentObject(PostFirebase())
}
