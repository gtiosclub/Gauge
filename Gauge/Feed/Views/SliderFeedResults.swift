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
                    .frame(height: 170)
                    .padding(.top, 8)
                
                // Profile photos here
                
                
                Text("\(post.calculateResponses().reduce(0, +)) votes")
                    .foregroundColor(Color.blackGray)
                    .font(.system(size: 12))
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
    let responses = [
        ///Option 1, 2/10 = 20%
        Response(responseId: "1", userId: "", responseOption: "1"),
        Response(responseId: "2", userId: "", responseOption: "1"),

        ///Option 2, 0/10 = 0%
        
        ///Option 3, 1/10 = 10%
        Response(responseId: "5", userId: "", responseOption: "3"),

        ///Option 4, 1/10 = 10%
        Response(responseId: "7", userId: "", responseOption: "4"),

        ///Option 4, 5/10 = 50%
        Response(responseId: "9", userId: "", responseOption: "5"),
        Response(responseId: "10", userId: "", responseOption: "5"),
        Response(responseId: "11", userId: "", responseOption: "5"),
        Response(responseId: "12", userId: "", responseOption: "5"),

        ///Option 4, 2/10 = 20%
        Response(responseId: "17", userId: "", responseOption: "6"),
        Response(responseId: "18", userId: "", responseOption: "6")
    ]

    let post = SliderPost(
        postId: "1",
        userId: "2lCFmL9FRjhY1v1NMogD5H6YuMV2",
        comments: [],
        responses: responses,
        categories: [.arts(.painting)],
        topics: [],
        postDateAndTime: Date(),
        question: "Picasso is the goat",
        lowerBoundLabel: "YES",
        upperBoundLabel: "NO",
        favoritedBy: []
    )



    SliderFeedResults(
        post: post,
        optionSelected: 4
    )
}
