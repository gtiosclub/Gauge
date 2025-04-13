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
        VStack(alignment: .leading, spacing: 12) {
            // Top row: Profile, name, badge, time
            HStack(spacing: 6) {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 36, height: 36)
                    .overlay(
                        Image(systemName: "dog.fill") // Placeholder profile icon
                            .resizable()
                            .scaledToFit()
                            .padding(8)
                            .foregroundColor(.gray)
                    )

                Text(username)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Image(systemName: "hexagon.fill")
                    .resizable()
                    .frame(width: 14, height: 14)
                    .foregroundColor(.yellow)

                Text("• \(timeAgo)")
                    .font(.footnote)
                    .foregroundColor(.gray)

                Spacer()
            }

            // Tags row
            HStack(spacing: 6) {
                ForEach(tags, id: \.self) { tag in
                    Text(tag)
                        .font(.caption)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.black)
                        .cornerRadius(20)
                }
                Spacer()
            }

            Text(content)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 16) {
                Text("\(votes) votes")
                
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
            }
            .font(.footnote)
            .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
    }
}



#Preview {
    TakesView()
        .environmentObject(UserFirebase())
        .environmentObject(PostFirebase())
}
