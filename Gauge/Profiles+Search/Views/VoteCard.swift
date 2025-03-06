//
//  VoteCard.swift
//  Gauge
//
//  Created by Jiya Bhatia on 2/28/25.
//

import SwiftUI

struct VoteCard: View {
    var username: String
    var timeAgo: String
    var tags: [String]
    var vote: String
    var content: String
    var comments: Int
    var views: Int
    var votes: Int // Number of votes

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Username and Time Ago
            HStack {
                Text(username)
                    .font(.headline)
                Spacer()
                Text(timeAgo)
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            // Tags
            HStack {
                ForEach(tags, id: \.self) { tag in
                    Text("#\(tag)")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }

            // Content
            Text(content)
                .font(.body)
                .padding(.vertical, 8)

            // Comments, Views, Votes, and Actions (Save, Share)
            HStack {
                // Comments
                HStack {
                    Image(systemName: "message.fill")
                        .foregroundColor(.gray)
                    Text("\(comments)")
                        .font(.caption)
                }

                // Views
                HStack {
                    Image(systemName: "eye.fill")
                        .foregroundColor(.gray)
                    Text("\(views)")
                        .font(.caption)
                }

                Spacer()

                // Votes
                Text("\(votes) Votes")
                    .font(.caption)
                    .padding(8)
                    .background(Color.white)
                    .foregroundColor(.black)
                    .cornerRadius(8)

                // Vote (Yes/No)
                Text(vote)
                    .font(.caption)
                    .padding(8)
                    .background(vote == "Yes" ? Color.green : Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)

                // Save Icon
                Button(action: {
                    // Action for saving
                }) {
                    Image(systemName: "bookmark.fill")
                        .foregroundColor(.gray)
                }

                // Share Icon
                Button(action: {
                    // Action for sharing
                }) {
                    Image(systemName: "square.and.arrow.up.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}
