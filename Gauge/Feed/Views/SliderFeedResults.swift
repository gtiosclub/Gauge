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
    SliderFeedResults()
}
