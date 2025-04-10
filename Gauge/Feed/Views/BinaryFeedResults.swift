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
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Results
                BinaryResultView(post: post, optionSelected: optionSelected)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 8)
                
                // Profile Stacks + Vote Count
                HStack {
                    StackedProfiles(
                        userIds: post.responses
                            .filter { userVM.user.friends.contains($0.userId) && $0.responseOption == post.responseOption1 }
                            .map { $0.userId },
                        sideOnTop: .left,
                        changeOffset: false
                    )
                    
                    Spacer()
                    
                    Text("\(post.calculateResponses().reduce(0, +)) votes")
                        .foregroundColor(Color.blackGray)
                        .font(.system(size: 12))
                    
                    Spacer()
                    
                    StackedProfiles(
                        userIds: post.responses
                            .filter { userVM.user.friends.contains($0.userId) && $0.responseOption == post.responseOption2 }
                            .map { $0.userId },
                        sideOnTop: .right
                    )
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
        post: BinaryPost(postId: "903885747", userId: "coolguy", categories: [.sports(.nfl), .sports(.soccer), .entertainment(.tvShows), .entertainment(.movies)], postDateAndTime: Date(), question: "Insert controversial binary take right here in this box; yeah, incite some intereseting discourse", responseOption1: "bad", responseOption2: "good", sublabel1: "bad", sublabel2: "great"),
        optionSelected: 2
    )
    .environmentObject(UserFirebase())
    .environmentObject(PostFirebase())
}
