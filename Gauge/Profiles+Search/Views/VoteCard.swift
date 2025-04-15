//
//  VoteCard.swift
//  Gauge
//
//  Created by Jiya Bhatia on 2/28/25.
//

import SwiftUI
struct VoteCard: View {
    var profilePhotoURL: String
    var username: String
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
        VStack(alignment: .leading, spacing: 12) {
            // Header: user info and vote
            HStack(spacing: 6) {
                AsyncImage(url: URL(string: profilePhotoURL)) { image in
                    image.resizable()
                } placeholder: {
                    Circle().fill(Color(.systemGray3))
                }
                .frame(width: 28, height: 28)
                .clipShape(Circle())
                Text(username)
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
            // Tags
            HStack(spacing: 6) {
                ForEach(tags, id: \.self) { tag in
                    Text(tag)
                        .font(.caption)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.gray.opacity(0.15))
                        .foregroundColor(.black)
                        .cornerRadius(20)
                }
            }
            // Content
            Text(content)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
            // Stats
            HStack {
                if let votes = votes {
                    Text("\(votes) votes")
                        .foregroundColor(.gray)
                        .font(.subheadline)
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
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
    }
}
