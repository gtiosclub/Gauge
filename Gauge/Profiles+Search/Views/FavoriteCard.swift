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
        VStack(alignment: .leading, spacing: 16) {
            // Top section: Profile image + username/timestamp + tags
            HStack(alignment: .top, spacing: 10) {
                AsyncImage(url: URL(string: post.profilePhoto)) { image in
                    image.resizable()
                } placeholder: {
                    Circle().fill(Color(.systemGray3))
                }
                .frame(width: 50, height: 50)
                .clipShape(Circle())

                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(post.username)
                            .font(.system(size: 20, weight: .semibold))
                        Text("• \(DateConverter.timeAgo(from: post.postDateAndTime)) ago")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }

                    HStack(spacing: 6) {
                        ForEach(post.categories, id: \.self) { tag in
                            Text(tag.rawValue)
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

            // Question content
            Text(post.question)
                .font(.system(size: 22))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
                .fixedSize(horizontal: false, vertical: true)

            // Stats + unfavorite button
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

            Divider()
        }
        .padding(20)
        .frame(minHeight: 200)
    }
}
