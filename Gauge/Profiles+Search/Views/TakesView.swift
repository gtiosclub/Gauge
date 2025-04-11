//
//  TakesView.swift
//  Gauge
//
//  Created by amber verma on 3/6/25.
//

import SwiftUI

struct TakesView: View {
    @EnvironmentObject var postVM: PostFirebase
    @EnvironmentObject var userVM: UserFirebase
    @State private var selectedPost: BinaryPost?

    var myBinaryPosts: [BinaryPost] {
        postVM.allQueriedPosts.compactMap { $0 as? BinaryPost }.filter { $0.userId == userVM.user.userId }
            .sorted { $0.postDateAndTime > $1.postDateAndTime }
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(myBinaryPosts, id: \.postId) { binary in
                    Button(action: {
                        selectedPost = binary
                    }) {
                        TakeCard(
                            username: binary.username,
                            timeAgo: DateConverter.timeAgo(from: binary.postDateAndTime),
                            tags: binary.categories.map { $0.rawValue },
                            content: binary.question,
                            votes: binary.calculateResponses().reduce(0, +),
                            comments: binary.comments.count,
                            views: binary.viewCounter
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
        }
        .onAppear {
            postVM.watchForNewPosts(user: userVM.user)
        }
        .sheet(item: $selectedPost) { post in
            if post.responses.contains(where: { $0.userId == userVM.user.userId }) {
                BinaryFeedResults(
                    post: post,
                    optionSelected: post.responses.first(where: { $0.userId == userVM.user.userId })?.responseOption == post.responseOption1 ? 1 : 2
                )
            } else {
                BinaryFeedPost(
                    post: post,
                    dragAmount: .constant(.zero),
                    optionSelected: .constant(0),
                    skipping: .constant(false)
                )
                .allowsHitTesting(false)
            }
        }
    }
}

struct TakeCard: View {
    var username: String
    var timeAgo: String
    var tags: [String]
    var content: String
    var votes: Int
    var comments: Int
    var views: Int

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 30, height: 30)
                Text(username)
                    .font(.headline)
                Image(systemName: "diamond")
                    .foregroundColor(.gray.opacity(0.7))
                Text("• \(timeAgo)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding(.bottom, 4)

            HStack {
                ForEach(tags, id: \.self) { tag in
                    Text("\(tag)")
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .font(.caption)
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.black)
                        .cornerRadius(8)
                }
                Spacer()
            }
            .padding(.bottom, 8)

            Text(content)
                .font(.body)
                .padding(.bottom, 8)

            HStack {
                Text("\(votes) votes")
                Spacer(minLength: 110)
                Image(systemName: "message")
                Text("\(comments)")
                Image(systemName: "eye")
                Text("\(views)")
                Spacer()
                Image(systemName: "bookmark")
                Image(systemName: "square.and.arrow.up")
            }
            .foregroundColor(.gray)
            .font(.subheadline)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 1)
    }
}

#Preview {
    TakesView()
        .environmentObject(UserFirebase())
        .environmentObject(PostFirebase())
}
