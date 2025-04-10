//
//  CommentView.swift
//  Gauge
//
//  Created by Krish Prasad on 2/22/25.
//

import SwiftUI

struct CommentView: View {
    @EnvironmentObject private var userVm: UserFirebase
    @EnvironmentObject private var postVm: PostFirebase
    let comment: Comment
    let profilePhotoSize: CGFloat = 25
    @State private var username: String = ""
    @State private var profilePhoto: String = ""
    @State var userStatus = "none"

    func fetchUserInfo() {
        userVm.getUsernameAndPhoto(userId: comment.userId) { info in
            username = info["username"] ?? ""
            profilePhoto = info["profilePhoto"] ?? ""
        }
        
        if comment.likes.contains(userVm.user.id) {
            userStatus = "liked"
        } else if comment.dislikes.contains(userVm.user.id) {
            userStatus = "disliked"
        } else {
        }
    }
    
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
                        .foregroundColor(color)
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
                    .background(color)
            }
            .padding(horizontalPadding)
        }
    }
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                VStack {
                    HStack(spacing: 4) {
                        if profilePhoto != "", let url = URL(string: profilePhoto) {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .frame(width: profilePhotoSize, height: profilePhotoSize)
                                        .clipShape(Circle())
                                case .failure, .empty:
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .frame(width: profilePhotoSize, height: profilePhotoSize)
                                        .foregroundColor(.gray)
                                @unknown default:
                                    EmptyView()
                                }
                            }
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: profilePhotoSize, height: profilePhotoSize)
                                .foregroundColor(.gray)
                        }
                        
                        Text(username)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                            .padding(.leading, 6)
                        
                        Text("•")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(Color(white: 0.5))
                        
                        Text("\(DateConverter.timeAgo(from: comment.date)) ago")
                            .font(.subheadline)
                            .foregroundColor(Color(white: 0.5))
                        
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
                                postVm.likeComment(postId: comment.postId, commentId: comment.commentId, userId: userVm.user.id)
                                userStatus = "liked"
                            } else {
                                postVm.removeLike(postId: comment.postId, commentId: comment.commentId, userId: userVm.user.id)
                                userStatus = "none"
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
                        
                        Text("\(comment.likes.count - comment.dislikes.count)")
                            .foregroundColor(userStatus == "liked" ? .green : (userStatus == "disliked") ? .red : Color(white: 0.5))
                        
                        Button {
                            print("Dislike Button")
                            if userStatus != "disliked" {
                                postVm.dislikeComment(postId: comment.postId, commentId: comment.commentId, userId: userVm.user.id)
                                userStatus = "disliked"
                            } else  {
                                postVm.removeDislike(postId: comment.postId, commentId: comment.commentId, userId: userVm.user.id)
                                userStatus = "none"
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
//                            postVm.likeComment(postId: comment.postId, commentId: comment.commentId, userId: userVm.user.id)
//                            userStatus = "liked"
//                        } else {
//                            postVm.removeLike(postId: comment.postId, commentId: comment.commentId, userId: userVm.user.id)
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
//                            postVm.dislikeComment(postId: comment.postId, commentId: comment.commentId, userId: userVm.user.id)
//                            userStatus = "disliked"
//                        } else  {
//                            postVm.removeDislike(postId: comment.postId, commentId: comment.commentId, userId: userVm.user.id)
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
        .padding(.horizontal, 25)
        .onAppear {
            fetchUserInfo()
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
    ))
    .environmentObject(UserFirebase())
    .environmentObject(PostFirebase())
}
