//
//  SliderFeedResults.swift
//  Gauge
//
//  Created by Sameer Arora on 4/9/25.
//

import SwiftUI

struct SliderFeedResults: View {
    @ObservedObject var post: SliderPost
    @EnvironmentObject var userVM: UserFirebase
    var optionSelected: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            VStack {
                Spacer(minLength: 30.0)
                    .frame(height: 30.0)
                
                ProfileUsernameDateView(dateTime: post.postDateAndTime, userId: post.userId)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 5)
                
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
                SliderResultView(post: post, optionSelected: optionSelected > 3 ? optionSelected - 1 : optionSelected)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .frame(height: 200)
                    .padding(.top, 8)
                    .padding(.bottom, 10)
                
                // Profile photos here
                
                
                Text("\(post.calculateResponses().reduce(0, +)) votes")
                    .foregroundColor(Color.blackGray)
                    .font(.system(size: 12))
            }
            .padding(.horizontal)

            // Comments
            CommentsView(post: post)
                .frame(maxWidth: .infinity)
                .padding(.top, 4)
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
    let responses = [
        ///Option 1, 2/10 = 20%
        Response(responseId: "1", userId: "", responseOption: "1"),
        Response(responseId: "2", userId: "idk6", responseOption: "1"),

        ///Option 2, 0/10 = 0%
        
        ///Option 3, 1/10 = 10%
        Response(responseId: "hi", userId: "hi", responseOption: "3"),

        ///Option 4, 1/10 = 10%
        Response(responseId: "7", userId: "", responseOption: "4"),

        ///Option 4, 5/10 = 50%
        Response(responseId: "9", userId: "", responseOption: "5"),
        Response(responseId: "10", userId: "idk4", responseOption: "5"),
        Response(responseId: "11", userId: "idk3", responseOption: "5"),
        Response(responseId: "12", userId: "idk2", responseOption: "5"),

        ///Option 4, 2/10 = 20%
        Response(responseId: "17", userId: "idk", responseOption: "2"),
        Response(responseId: "18", userId: "Rzqik2ISWBezcmBVVaoCbR4rCz92", responseOption: "6")
    ]

    let post = SliderPost(
        postId: "1",
        userId: "Rzqik2ISWBezcmBVVaoCbR4rCz92",
        comments: [Comment(commentType: .text, postId: "idk", userId: "Rzqik2ISWBezcmBVVaoCbR4rCz92", date: Date.now, commentId: "1", likes: [], dislikes: [], content: "hi!"), Comment(commentType: .text, postId: "idk", userId: "idk", date: Date.now, commentId: "1", likes: [], dislikes: [], content: "hi!"), Comment(commentType: .text, postId: "idk", userId: "hi", date: Date.now, commentId: "1", likes: [], dislikes: [], content: "hey!")],
        responses: responses,
        categories: [.arts(.painting)],
        topics: [],
        postDateAndTime: Date(),
        question: "Picasso is the goat",
        lowerBoundLabel: "YES",
        upperBoundLabel: "NO",
        favoritedBy: []
    )

    var user = UserFirebase()
    user.user = User(userId: "", username: "", phoneNumber: "", email: "", friendIn: [], friendOut: [], friends: ["Rzqik2ISWBezcmBVVaoCbR4rCz92","idk","idk2","idk3","idk4","idk5","idk6"], myNextPosts: [], myResponses: [], myFavorites: [], myPostSearches: [], myProfileSearches: [], myComments: [], myCategories: [], myTopics: [], badges: [], streak: 1, profilePhoto: "", myAccessedProfiles: [], lastLogin: Date.now, lastFeedRefresh: Date.now, attributes: [:], myTakeTime: [:])
    
    return SliderFeedResults(
        post: post,
        optionSelected: 4
    )
    .environmentObject(user)
}
