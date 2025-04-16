//
//  VoteCard.swift
//  Gauge
//
//  Created by Jiya Bhatia on 2/28/25.
//

import SwiftUI

struct VoteCard: View {
    var voterName: String?
    var profilePhotoURL: String?
    var username: String?
    var timeAgo: String
    var tags: [String]
    var vote: String
    var content: String
    var comments: Int?
    var views: Int?
    var votes: Int?

    var voteColor: Color {
        let greenResponses = ["yes", "love", "cool"]
        return greenResponses.contains(vote.lowercased()) ? .green : .red
    }

    var voteText: String {
        "voted \(vote.lowercased())"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            // Top row: voter + vote
            if let voterName = voterName {
                HStack(spacing: 4) {
                    Text(voterName)
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    Text("·")
                        .foregroundColor(.gray)

                    Text(voteText)
                        .foregroundColor(voteColor)
                        .font(.subheadline)

                    Spacer()

                    Text(timeAgo)
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
            }

            // Middle row: original post author + tags
            HStack(alignment: .top, spacing: 10) {
                if let profilePhotoURL = profilePhotoURL {
                    AsyncImage(url: URL(string: profilePhotoURL)) { image in
                        image.resizable()
                    } placeholder: {
                        Circle().fill(Color(.systemGray3))
                    }
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                }

                VStack(alignment: .leading, spacing: 6) {
                    if let username = username {
                        HStack(spacing: 6) {
                            Text(username)
                                .font(.system(size: 20, weight: .semibold))

                            Text("• \(timeAgo)")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
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

            // Content
            Text(content)
                .font(.system(size: 22))
                .foregroundColor(.black)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.leading, 60)

            // Interaction Row
            HStack {
                if let votes = votes {
                    Text("\(votes) votes")
                        .foregroundColor(.gray)
                        .font(.subheadline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.leading, 60)

                }

                Spacer()

                HStack(spacing: 16) {
                    if let comments = comments {
                        HStack(spacing: 4) {
                            Image(systemName: "bubble.left")
                            Text("\(comments)")
                        }
                    }

                    if let views = views {
                        HStack(spacing: 4) {
                            Image(systemName: "eye")
                            Text("\(views)")
                        }
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
