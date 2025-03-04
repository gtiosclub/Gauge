//
//  BinaryFeedResults.swift
//  Gauge
//
//  Created by Austin Huguenard on 3/3/25.
//

import SwiftUI

struct BinaryFeedResults: View {
    var post: BinaryPost
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                VStack {
                    Text("NEXT")
                        .foregroundStyle(.gray)
                        .opacity(0.5)
                    
                    Image(systemName: "arrow.down")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30, alignment: .center)
                        .foregroundStyle(.gray)
                        .opacity(0.5)
                }
                
                Spacer()
            }
            
            HStack {
                profileImage
                
                Text(post.userId)
                    .font(.system(size: 16))
                    .padding(.leading, 10)
                
                Text("•   \(DateConverter.timeAgo(from: post.postDateAndTime))")
                    .font(.system(size: 13))
                    .padding(.leading, 5)
                    .foregroundStyle(.gray)
                
                Spacer()
            }
            .padding(.horizontal)
            
            HStack {
                Text(post.question)
                    .padding(.top, 10)
                    .font(.system(size: 25))
                    .frame(alignment: .leading)
                    
                Spacer()
            }
            .padding(.horizontal)
            
            BinaryResultView(post: post)
            
            Text("\(post.responseResult1 + post.responseResult2) votes")
                .foregroundColor(.gray)
            
            Spacer(minLength: 10.0)
            
            CommentsView(comments: post.comments)
            
            Spacer()
        }
        .padding()
    }
    
    var profileImage: some View {
        if post.profilePhoto == "" {
            AnyView(Image(systemName: "person")
                .resizable()
                .scaledToFit()
                .frame(width: 18, height: 18)
                .background(Circle()
                    .fill(Color.gray)
                    .frame(width:28, height: 28)
                    .opacity(0.6)
                )
            )
        } else {
            AnyView(AsyncImage(url: URL(string: post.profilePhoto)) { image in
                image.resizable()
                    .scaledToFill()
                    .frame(width: max(120, 140))
                    .frame(height: 120)
                    .cornerRadius(10)
                    .shadow(color: .black.opacity(0.5), radius: 5, y: 3)
            } placeholder: {
                ProgressView() // Placeholder until the image is loaded
                    .frame(width: max(120, 140))
                    .frame(height: 120)
                    .cornerRadius(10)
            }
            )
        }
    }
}

#Preview {
    BinaryFeedResults(post: BinaryPost(postId: "903885747", userId: "coolguy", categories: [.sports(.nfl), .sports(.soccer), .entertainment(.tvShows), .entertainment(.movies)], postDateAndTime: Date(), question: "Insert controversial binary take right here in this box; yeah, incite some intereseting discourse", responseOption1: "bad", responseOption2: "good"))
}
