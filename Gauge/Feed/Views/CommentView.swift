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
    @State var userLiked = 0
    
    func fetchUserInfo() {
        userVm.getUsernameAndPhoto(userId: comment.userId) { info in
            username = info["username"] ?? ""
            profilePhoto = info["profilePhoto"] ?? ""
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
                        if userLiked != 1 {
                            postVm.likeComment(postId: comment.postId, commentId: comment.commentId, userId: comment.userId)
                            userLiked = 1
                        } else {
                            postVm.removeLike(postId: comment.postId, commentId: comment.commentId, userId: comment.userId)
                            userLiked = 0
                        }
                        
                    }) {
                        Image(systemName: "arrow.up")
                            .resizable()
                            .frame(width: 11, height: 13)
                            .fontWeight(.semibold)
                            .foregroundColor(userLiked == 1 ? .blue : .black)
                    }
                    
                    Text("\(comment.likes.count - comment.dislikes.count + userLiked)")
                        .font(.callout)
                    
                    Button(action: {
                        if userLiked != -1 {
                            postVm.dislikeComment(postId: comment.postId, commentId: comment.commentId, userId: comment.userId)
                            userLiked = -1
                        } else  {
                            postVm.removeDislike(postId: comment.postId, commentId: comment.commentId, userId: comment.userId)
                            userLiked = 0
                        }
                    }) {
                        Image(systemName: "arrow.down")
                            .resizable()
                            .frame(width: 11, height: 13)
                            .fontWeight(.semibold)
                            .foregroundColor(userLiked == -1 ? .blue : .black)
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
