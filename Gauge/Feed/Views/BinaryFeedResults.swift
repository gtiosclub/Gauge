//
//  BinaryFeedResults.swift
//  Gauge
//
//  Created by Austin Huguenard on 3/3/25.
//

import SwiftUI

struct BinaryFeedResults: View {
    @ObservedObject var post: BinaryPost
    @EnvironmentObject var userVM: UserFirebase

    var optionSelected: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            VStack {
                Spacer(minLength: 30.0)
                    .frame(height: 30.0)
                
                ProfileUsernameDateView(dateTime: post.postDateAndTime, userId: post.userId)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Categories
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(post.categories, id: \.self) { category in
                            Text(category.rawValue)
                                .padding(.vertical, 4)
                                .padding(.horizontal, 10)
                                .font(.system(size: 14))
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(height: 32)
                                )
                        }
                    }
                    .padding(.vertical, 6)
                }
                
                // Question
                Text(post.question)
                    .bold()
                    .font(.system(size: 35))
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.black)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Results
                BinaryResultView(post: post, optionSelected: optionSelected)
//                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 4)
                
                // Profile Stacks + Vote Count
                
                ZStack {
                    HStack {
                        StackedProfiles(
                            userIds: Array(post.responses
                                .filter { userVM.user.friends.contains($0.userId) && $0.responseOption == post.responseOption1 }
                                .map { $0.userId }.prefix(3)),
                            sideOnTop: .left,
                            changeOffset: false
                        )
                        
                        Spacer()
                        
                        StackedProfiles(
                            userIds: Array(post.responses
                                .filter { userVM.user.friends.contains($0.userId) && $0.responseOption == post.responseOption2 }
                                .map { $0.userId }.prefix(3)),
                            sideOnTop: .right,
                            changeOffset: false
                        )
                    }
                    
                    HStack {
                        Spacer()
                        
                        Text("\(post.calculateResponses().reduce(0, +)) votes")
                            .foregroundColor(Color.blackGray)
                            .font(.system(size: 12))
                        
                        Spacer()
                    }
                }
                .padding(.top, 5)
            }
            .padding(.horizontal)

            // Comments
            CommentsView(post: post)
                .frame(maxWidth: .infinity)
                .padding(.top, 12)
                .padding(.horizontal, 0)
                .onChange(of: post.comments) {old, new in
                    print("recognized comments changed")
                }
            
            Spacer()
                .frame(height: 5.0)
        }
    }
}

#Preview {
    BinaryFeedResults(
        post: BinaryPost(postId: "903885747", userId: "coolguy", comments: [Comment(commentType: .text, postId: "903885747", userId: "1", date: Date.now, commentId: "1", likes: [], dislikes: [], content: "Hey!")],
                         responses:
                            [Response(responseId: "1", userId: "1", responseOption: "Yes"),
                         Response(responseId: "1", userId: "2", responseOption: "No"),
                         Response(responseId: "1", userId: "3", responseOption: "No"),
                         Response(responseId: "1", userId: "4", responseOption: "Yes"),
                         Response(responseId: "1", userId: "5", responseOption: "No"),
                         Response(responseId: "1", userId: "6", responseOption: "No"),
                         Response(responseId: "1", userId: "7", responseOption: "No"),
                         Response(responseId: "1", userId: "8", responseOption: "No"),
                         Response(responseId: "1", userId: "9", responseOption: "No"),
                         Response(responseId: "1", userId: "10", responseOption: "No"),
                         Response(responseId: "2", userId: "11", responseOption: "No")],
                         categories: [.sports(.nfl), .sports(.soccer)],
                        topics: ["art", "picasso"],
                         postDateAndTime: Date(), question: "Insert controversial binary take right here in this box;", responseOption1: "No", responseOption2: "Yes", sublabel1: "bad", sublabel2: "great", favoritedBy: ["sameer"]),
        optionSelected: 2
    )
    .environmentObject(UserFirebase())
    .environmentObject(PostFirebase())
}
