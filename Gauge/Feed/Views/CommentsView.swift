//
//  CommentsView.swift
//  Gauge
//
//  Created by Krish Prasad on 2/27/25.
//

import SwiftUI

struct CommentsView: View {
    @EnvironmentObject private var userVM: UserFirebase
    @EnvironmentObject private var postVM: PostFirebase
    @State private var sortOption: SortOption = .mostVotes
    @State var newCommentText: String = ""
    @State var showAddComment: Bool = false
    @State private var isBookmarked: Bool = false
    var post: any Post
    
    enum SortOption: String, CaseIterable {
        case mostVotes = "Most votes"
        case mostRecent = "Most recent"
    }
    
    var sortedComments: [Comment] {
        switch sortOption {
        case .mostVotes:
            return post.comments.sorted {
                ($0.likes.count - $0.dislikes.count) > ($1.likes.count - $1.dislikes.count)
            }
        case .mostRecent:
            return post.comments.sorted {
                $0.date > $1.date
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
                .background(Color.gray.opacity(0.4))
            HStack {
                Image(systemName: "arrow.up.arrow.down")
                    .font(.system(size: 12))
                
                Text("Sort by:")
                    .font(.system(size: 12))
                Menu {
                    ForEach(SortOption.allCases, id: \.self) { option in
                        Button(option.rawValue) {
                            sortOption = option
                        }
                    }
                } label: {
                    HStack {
                        
                        Text(sortOption.rawValue)
                            .font(.system(size: 12, weight: .bold))
                        
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(.black)
                    .background(Color.whiteGray)
                    .padding(10)
                    .background(
                        Capsule()
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                }
                
                Spacer()
                
                // Comment count
                Button(action: {
                    showAddComment = true
                }) {
                    HStack {
                        Image(systemName: "bubble.left")
                            .font(.system(size: 12))
                        
                        Text("\(post.comments.count)")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .padding(10)
                    .foregroundColor(.black)
                    .background(
                        Capsule()
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .background(Color.whiteGray)
                }
                
                // Bookmark button
                Button(action: {
                    isBookmarked.toggle()
                    postVM.addUserToFavoritedBy(postId: post.postId, userId: userVM.user.id)
                }) {
                    Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 18))
                        .foregroundColor(isBookmarked ? .blue : .black)
                        .padding(10)
                        .background(
                            Circle()
                                .fill(Color.blue.opacity(isBookmarked ? 0.1 : 0))
                                .stroke(Color.gray.opacity(0.3), lineWidth: isBookmarked ? 0 : 1)
                        )
                        .background(Color.whiteGray)
                }
            }
            .padding()
            .background(Color.whiteGray)
            
            // Comments list
            ScrollView {
                if post.comments.isEmpty {
                    VStack(spacing: 8) {
                        Spacer()
                        
                        // Cricket icons using emoji
                        HStack(spacing: 4) {
                            Text("🦗")
                                .font(.system(size: 24))
                            Text("🦗")
                                .font(.system(size: 24))
                        }
                        
                        Text("*crickets*")
                            .font(.system(size: 24, weight: .medium))
                        
                        Text("Be the first to comment")
                            .font(.system(size: 18))
                            .foregroundColor(.secondary)
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 60)
                } else {
                    LazyVStack(spacing: 0) {
                        ForEach(sortedComments, id: \.self) { comment in
                            CommentView(comment: comment, post: post)
                                .padding(.vertical, 12)
                            
                            Rectangle()
                                .fill(Color.whiteGray)
                                .frame(height: 6)
                        }
                    }
                    .background(Color.white)
                }
            }
            .background(Color.whiteGray)
        }
        .background(Color.whiteGray)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .sheet(isPresented: $showAddComment) {
            ZStack {
                    CommentSheetView(showAddComment: $showAddComment, post: post)
                        .padding()
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(radius: 8)
                }
                .presentationDetents([.height(200)])
        }
    }
}
    
//    #Preview {
//        CommentsView(
//            comments: [
//                Comment(
//                    commentType: .text,
//                    postId: "555555555",
//                    userId: "Lv72Qz7Qc4TC2vDeE94q",
//                    date: Date(),
//                    commentId: "",
//                    likes: [],
//                    dislikes: [],
//                    content: "Love seeing all the amazing things happening here! Keep up the great work, everyone. 💯✨ #Inspiration #Communityee. Love seeing all the amazing things happening here! Keep up the great work, everyone. 💯✨ #Inspiration #Community."
//                ),
//                Comment(
//                    commentType: .text,
//                    postId: "555555555",
//                    userId: "Lv72Qz7Qc4TC2vDeE94q",
//                    date: Date(),
//                    commentId: "",
//                    likes: [],
//                    dislikes: [],
//                    content: "Love seeing all the amazing things happening here! Keep up the great work, everyone. 💯✨ #Inspiration #Communitwwy. Love seeing all the amazing things happening here! Keep up the great work, everyone. 💯✨ #Inspiration #Community."
//                )
//            ], postId: "2C263425-873B-4CD8-89DF-84B1F5A02FF0")
//        .environmentObject(UserFirebase())
//    }
//}
 
