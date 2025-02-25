//
//  CommentView.swift
//  Gauge
//
//  Created by Krish Prasad on 2/22/25.
//

import SwiftUI

struct CommentView: View {
    @EnvironmentObject private var userVm: UserFirebase
    let comment: Comment
    let profilePhotoSize: CGFloat = 30
    @State private var username: String = ""
    @State private var profilePhoto: String = ""
    
    func fetchUserInfo() {
        userVm.getUsernameAndPhoto(userId: comment.userId) { info in
            username = info["username"] ?? ""
            profilePhoto = info["profilePhoto"] ?? ""
        }
    }
    
    var body: some View {
        ZStack {
            HStack(spacing: 3) {
                //Profile Photo
                if profilePhoto != "", let url = URL(string: profilePhoto) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .frame(width: profilePhotoSize, height: profilePhotoSize)
                                .padding(.trailing, 4)
                                .clipShape(Circle())
                        case .failure, .empty:
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: profilePhotoSize, height: profilePhotoSize)
                                .padding(.trailing, 4)
                                .foregroundColor(.gray)
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: profilePhotoSize, height: profilePhotoSize)
                        .padding(.trailing, 4)
                        .foregroundColor(.gray)
                }
                
                Text(username)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(white: 0.4))
                Text("• 1d ago")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(white: 0.6))
            }
            .position(x: 90, y: 25)
            
            
            Text(comment.content)
                .lineLimit(nil)
                .frame(maxWidth: 350, maxHeight: 100, alignment: .topLeading)
                .foregroundColor(Color(white: 0.2))
                .position(x: 183, y: 95)
            
            
            VStack(spacing: 10) {
                Button(action: {}) {
                    Image(systemName: "arrow.up")
                        .resizable()
                        .frame(width: 15, height: 20)
                }
                
                Text("\(comment.likes.count)")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Button(action: {}) {
                    Image(systemName: "arrow.down")
                        .resizable()
                        .frame(width: 15, height: 20)
                }
            }
            .position(x: 375, y: 70)
            .foregroundColor(.black)
            .padding(.trailing)
        }
        .frame(maxHeight: 120)
        .onAppear {
            fetchUserInfo()
        }
    }
}

#Preview {
    CommentView(comment: Comment(
        commentType: .text,
        userId: "Lv72Qz7Qc4TC2vDeE94q",
        date: Date(),
        commentId: "",
        likes: [],
        dislikes: [],
        content: "This is a really cool nice comment on this post. This post is so cool and nice I really like this post I'm so positive and happy and nice and cool. This is a really cool nice comment on this post. This post is so cool and nice I really like this post I'm so positive and happy and nice and cool."
    ))
}
