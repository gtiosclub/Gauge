//
//  SliderFeedResults.swift
//  Gauge
//
//  Created by Sameer Arora on 4/9/25.
//

import SwiftUI

struct SliderFeedResults: View {
    @ObservedObject var post: SliderPost
    var optionSelected: Int
    
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
            
            Spacer(minLength: 30.0)
            
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
                    .fontWeight(.bold)
                    
                Spacer()
            }
            .padding(.horizontal)
            
            SliderResultView(post: post, optionSelected: optionSelected)
                .padding(.top, 10)
                
            Text("\(post.calculateResponses().reduce(0, +)) votes")
                .foregroundColor(.gray)
                .padding(.top, 10)
                        
            withAnimation(.none, {
                CommentsView(comments: post.comments)
                    .onChange(of: post.comments) {old, new in
                            print("recognized  commentschanged")
                    }
            })
        }
        .padding()
        .onAppear() {
            print(post.responses)
        }
    }
    
    var profileImage: some View {
        if post.profilePhoto == "" {
            AnyView(Image(systemName: "person")
                .resizable()
                .scaledToFit()
                .frame(width: 18, height: 18)
                .background(Circle()
                    .fill(Color.gray.opacity(0.7))
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
    let responses = [
        ///Option 1, 2/10 = 20%
        Response(responseId: "1", userId: "", responseOption: "1"),
        Response(responseId: "2", userId: "", responseOption: "1"),

        ///Option 2, 0/10 = 0%
        
        ///Option 3, 1/10 = 10%
        Response(responseId: "5", userId: "", responseOption: "3"),

        ///Option 4, 1/10 = 10%
        Response(responseId: "7", userId: "", responseOption: "4"),

        ///Option 4, 5/10 = 50%
        Response(responseId: "9", userId: "", responseOption: "5"),
        Response(responseId: "10", userId: "", responseOption: "5"),
        Response(responseId: "11", userId: "", responseOption: "5"),
        Response(responseId: "12", userId: "", responseOption: "5"),

        ///Option 4, 2/10 = 20%
        Response(responseId: "17", userId: "", responseOption: "6"),
        Response(responseId: "18", userId: "", responseOption: "6")
    ]

    var post = SliderPost(
        postId: "1",
        userId: "2lCFmL9FRjhY1v1NMogD5H6YuMV2",
        categories: [.arts(.painting)],
        postDateAndTime: Date(),
        question: "Picasso is the goat",
        lowerBoundLabel: "YES",
        upperBoundLabel: "NO",
        lowerBoundValue: 1.0,
        upperBoundValue: 6.0
    )
    
    post.responses = responses

    return SliderFeedResults(
        post: post,
        optionSelected: 4
    )
}
