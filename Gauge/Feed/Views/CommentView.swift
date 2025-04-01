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
    let profilePhotoSize: CGFloat = 30
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
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                VStack {
                    HStack(spacing: 4) {
                        //Profile Photo
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
                            .foregroundColor(Color(white: 0.4))
                        
                        Text("• \(DateConverter.timeAgo(from: comment.date))")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(Color(white: 0.6))
                        
                        Spacer()
                        
                    }
                    .frame(alignment: .leading)
                    
                    HStack {
                        ExpandableText(comment.content)
                            .lineLimit(nil)
                            .frame(alignment: .topLeading)
                            .foregroundColor(Color(white: 0.2))
                        
                        Spacer()
                    }
                    
                }
                
                
                VStack(spacing: 7) {
                    Button(action: {
                        if userStatus != "liked" {
                            postVm.likeComment(postId: comment.postId, commentId: comment.commentId, userId: userVm.user.id)
                            userStatus = "liked"
                        } else {
                            postVm.removeLike(postId: comment.postId, commentId: comment.commentId, userId: userVm.user.id)
                            userStatus = "none"
                        }
                        
                    }) {
                        Image(systemName: "arrow.up")
                            .resizable()
                            .frame(width: 11, height: 13)
                            .fontWeight(.semibold)
                            .foregroundColor(userStatus == "liked" ? .blue : .black)
                    }
                    
                    Text("\(comment.likes.count - comment.dislikes.count)")
                        .font(.callout)
                    
                    Button(action: {
                        if userStatus != "disliked" {
                            postVm.dislikeComment(postId: comment.postId, commentId: comment.commentId, userId: userVm.user.id)
                            userStatus = "disliked"
                        } else  {
                            postVm.removeDislike(postId: comment.postId, commentId: comment.commentId, userId: userVm.user.id)
                            userStatus = "none"
                        }
                    }) {
                        Image(systemName: "arrow.down")
                            .resizable()
                            .frame(width: 11, height: 13)
                            .fontWeight(.semibold)
                            .foregroundColor(userStatus == "disliked" ? .blue : .black)
                    }
                }
                .foregroundColor(.black)
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
        userId: "uCLGAxWCWFMRm4Qlt06z",
        date: Calendar.current.date(byAdding: .hour, value: -5, to: Date())!,
        commentId: "WiIaeW7EIlTr7Mq97PkI",
        likes: [],
        dislikes: [],
        content: "Love seeing all the amazing things happening here! Keep up the great work, everyone. 💯✨ #Inspiration #Community. Love seeing all the amazing things happening here! Keep up the great work, everyone. 💯✨ #Inspiration #Community."
    ))
    .environmentObject(UserFirebase())
    .environmentObject(PostFirebase())
}
