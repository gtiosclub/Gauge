//
//  TakesView.swift
//  Gauge
//
//  Created by amber verma on 3/6/25.
//

import SwiftUI

struct TakesView: View {
    @EnvironmentObject var postVM: PostFirebase
    
    var body: some View {
        ScrollView {
            VStack {
                if postVM.feedPosts.count >= 1, let post1 = postVM.feedPosts[0] as? BinaryPost {
                    TakeCard(
                        username: post1.username,
                        timeAgo: "1 hr",
                        tags: ["lifestyle", "homeDecor"],
                        content: post1.question,
                        votes: 100,
                        comments: 10,
                        views: 200
                    )
                }
                
                if postVM.feedPosts.count >= 2, let post2 = postVM.feedPosts[1] as? BinaryPost {
                    let tags = post2.categories.map { String(describing: $0) }
                    TakeCard(
                        username: post2.username,
                        timeAgo: "2 hrs",
                        tags: ["funny", "tvShows", "politics"],
                        content: post2.question,
                        votes: 100,
                        comments: 10,
                        views: 200
                    )
                }
                TakeCard(username: "UserA", timeAgo: "2d ago", tags: ["tag1", "tag2", "tag3"], content: "UserA own personal take on something controversial", votes: 100, comments: 10, views: 200)
                TakeCard(username: "UserB", timeAgo: "5d ago", tags: ["tag1", "tag2", "tag3"], content: "UserB own personal take on something controversial", votes: 100, comments: 10, views: 200)
            }
            .padding()
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
                        .frame(width: 30, height: 30) // Placeholder for profile image
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
                        Text("#\(tag)")
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
            .environmentObject(PostFirebase())
    }
