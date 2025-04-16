//
//  TakesView.swift
//  Gauge
//
//  Created by amber verma on 3/6/25.
//

import SwiftUI

struct TakesView: View {
    var visitedUser: User
    @ObservedObject var profileVM: ProfileViewModel
    @State private var selectedPost: BinaryPost?
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(profileVM.posts, id: \.postId) { post in
                    Button {
                        selectedPost = post
                    } label: {
                        TakeCard(
                            username: visitedUser.username,
                            profilePhotoURL: visitedUser.profilePhoto,
                            timeAgo: DateConverter.timeAgo(from: post.postDateAndTime),
                            tags: post.categories.map { $0.rawValue },
                            content: post.question,
                            votes: post.calculateResponses().reduce(0, +),
                            comments: post.comments.count,
                            views: post.viewCounter
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
        }
        .onAppear {
            profileVM.fetchUserPosts(for: visitedUser.userId)
        }
        .sheet(item: $selectedPost, onDismiss: {
            profileVM.fetchUserPosts(for: visitedUser.userId)
        }) { post in
            SwipeableTakeSheetView(post: post)
                .presentationDetents([.fraction(0.94)])
                .presentationBackground(Color.white)
        }
    }
}
    
struct SwipeableSheetWrapper: View {
    @ObservedObject var post: BinaryPost
    @EnvironmentObject var postVM: PostFirebase
    @EnvironmentObject var userVM: UserFirebase
    @State private var dragAmount: CGSize = .zero
    @State private var optionSelected: Int = 0
    @State private var skipping: Bool = false
    @State private var isConfirmed: Bool = false
    var body: some View {
        VStack {
            if isConfirmed || post.responses.contains(where: { $0.userId == userVM.user.userId }) {
                BinaryFeedResults(
                    post: post,
                    optionSelected: optionSelectedFromResponse()
                )
            } else {
                BinaryFeedPost(
                    post: post,
                    dragAmount: $dragAmount,
                    optionSelected: $optionSelected,
                    skipping: $skipping
                )
                .onChange(of: optionSelected) { _, newValue in
                    if newValue != 0 {
                        submitResponse(for: newValue)
                    }
                }
            }
        }
        .padding(.top, 30)
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
    private func optionSelectedFromResponse() -> Int {
        if let response = post.responses.first(where: { $0.userId == userVM.user.userId }) {
            return response.responseOption == post.responseOption1 ? 1 : 2
        }
        return 0
    }
    private func submitResponse(for selection: Int) {
        let selectedOption = selection == 1 ? post.responseOption1 : post.responseOption2
        postVM.addResponse(postId: post.postId, userId: userVM.user.userId, responseOption: selectedOption)
        isConfirmed = true
    }
}

struct SwipeableSheetView: View {
    @ObservedObject var post: BinaryPost
    @EnvironmentObject var postVM: PostFirebase
    @EnvironmentObject var userVM: UserFirebase
    @State private var dragAmount: CGSize = .zero
    @State private var optionSelected: Int = 0
    @State private var skipping: Bool = false
    @State private var isConfirmed: Bool = false
    var body: some View {
        VStack {
            if isConfirmed || post.responses.contains(where: { $0.userId == userVM.user.userId }) {
                BinaryFeedResults(post: post, optionSelected: post.responses.first(where: { $0.userId == userVM.user.userId })?.responseOption == post.responseOption1 ? 1 : 2)
            } else {
                BinaryFeedPost(
                    post: post,
                    dragAmount: $dragAmount,
                    optionSelected: $optionSelected,
                    skipping: $skipping
                )
                .onChange(of: optionSelected) { _, newValue in
                    if newValue != 0 {
                        let selectedOption = newValue == 1 ? post.responseOption1 : post.responseOption2
                        postVM.addResponse(postId: post.postId, userId: userVM.user.userId, responseOption: selectedOption)
                        isConfirmed = true
                    }
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
}

struct TakeCard: View {
    var username: String
    var profilePhotoURL: String
    var timeAgo: String
    var tags: [String]
    var content: String
    var votes: Int
    var comments: Int
    var views: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Top section: Profile image + username/timestamp/tags
            HStack(alignment: .top, spacing: 10) {
                AsyncImage(url: URL(string: profilePhotoURL)) { image in
                    image.resizable()
                } placeholder: {
                    Circle().fill(Color(.systemGray3))
                }
                .frame(width: 50, height: 50)
                .clipShape(Circle())

                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(username)
                            .font(.system(size: 20, weight: .semibold))
                        Text("• \(timeAgo) ago")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }

                    HStack(spacing: 6) {
                        ForEach(tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color(.systemGray5))
                                .cornerRadius(10)
                        }
                    }
                }

                Spacer()
            }

            Text(content)
                .font(.system(size: 22))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
                .fixedSize(horizontal: false, vertical: true)

            // Interaction Row
            HStack {
                Text("\(votes) votes")
                    .foregroundColor(.gray)
                    .font(.subheadline)

                Spacer()

                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Image(systemName: "bubble.left")
                        Text("\(comments)")
                    }

                    HStack(spacing: 4) {
                        Image(systemName: "eye")
                        Text("\(views)")
                    }

                    Image(systemName: "bookmark")
                    Image(systemName: "square.and.arrow.up")
                }
                .foregroundColor(.gray)
                .font(.subheadline)
            }

            Divider()
        }
        .padding(20)
        .frame(minHeight: 200)
    }
}

