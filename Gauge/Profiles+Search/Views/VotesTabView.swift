//
//  VotesTabView.swift
//  Gauge
//
//  Created by amber verma on 4/14/25.
//

import SwiftUI

struct VotesTabView: View {
    var visitedUser: User
    @ObservedObject var profileVM: ProfileViewModel

    var body: some View {
        if profileVM.respondedPosts.isEmpty {
            ProgressView("Loading...")
        } else {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(profileVM.respondedPosts, id: \.postId) { post in
                        if let userResponse = post.responses.first(where: { $0.userId == visitedUser.userId }) {
                            VoteCard(
                                profilePhotoURL: visitedUser.profilePhoto,
                                username: visitedUser.username,
                                timeAgo: DateConverter.timeAgo(from: post.postDateAndTime),
                                tags: post.categories.map { $0.rawValue },
                                vote: userResponse.responseOption,
                                content: post.question,
                                comments: post.comments.count,
                                views: post.viewCounter,
                                votes: post.calculateResponses().reduce(0, +)
                            )
                        }
                    }
                }
                .padding()
            }
        }
    }
}
