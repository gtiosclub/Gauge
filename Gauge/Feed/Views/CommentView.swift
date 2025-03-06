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
                    Button(action: {}) {
                        Image(systemName: "arrow.up")
                            .resizable()
                            .frame(width: 11, height: 13)
                            .fontWeight(.semibold)
                    }
                    
                    Text("\(comment.likes.count - comment.dislikes.count)")
                        .font(.callout)
                    
                    Button(action: {}) {
                        Image(systemName: "arrow.down")
                            .resizable()
                            .frame(width: 11, height: 13)
                            .fontWeight(.semibold)
                    }
                }
                //.position(x: 365, y: 70)
                .foregroundColor(.black)
            }
            Spacer()
        }
        .padding(.horizontal, 25)
        .onAppear {
//            fetchUserInfo()
            username = comment.username
        }
    }
}

#Preview {
    CommentView(comment: Comment(
        commentType: .text,
        userId: "Lv72Qz7Qc4TC2vDeE94q",
        date: Calendar.current.date(byAdding: .hour, value: -5, to: Date())!,
        commentId: "",
        likes: [],
        dislikes: [],
        content: "Love seeing all the amazing things happening here! Keep up the great work, everyone. 💯✨ #Inspiration #Community. Love seeing all the amazing things happening here! Keep up the great work, everyone. 💯✨ #Inspiration #Community."
    ))
    .environmentObject(UserFirebase())
}
