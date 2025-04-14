//
//  FavoriteCard.swift
//  Gauge
//
//  Created by amber verma on 4/14/25.
//

import SwiftUI

struct FavoriteCard: View {
    var post: BinaryPost
    var onUnfavorite: () -> Void

    @EnvironmentObject var userVM: UserFirebase
    @EnvironmentObject var postVM: PostFirebase

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ProfileUsernameDateView(dateTime: post.postDateAndTime, userId: post.userId)

            // Tags
            HStack(spacing: 6) {
                ForEach(post.categories, id: \.self) { tag in
                    Text(tag.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.gray.opacity(0.15))
                        .cornerRadius(20)
                }
            }

            // Question
            Text(post.question)
                .font(.system(size: 16))
                .foregroundColor(.black)
                .fixedSize(horizontal: false, vertical: true)

            // Stats
            HStack {
                Text("\(post.calculateResponses().reduce(0, +)) votes")
                    .foregroundColor(.gray)
                    .font(.subheadline)

                Spacer()

                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Image(systemName: "bubble.left")
                        Text("\(post.comments.count)")
                    }

                    HStack(spacing: 4) {
                        Image(systemName: "eye")
                        Text("\(post.viewCounter)")
                    }

                    // Bookmark filled icon
                    Button(action: {
                        postVM.removeUserFromFavoritedBy(postId: post.postId, userId: userVM.user.userId)
                        onUnfavorite()
                    }) {
                        Image(systemName: "bookmark.fill")
                    }
                }
                .foregroundColor(.gray)
                .font(.subheadline)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
    }
}

