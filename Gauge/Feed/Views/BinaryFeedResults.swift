//
//  BinaryFeedResults.swift
//  Gauge
//
//  Created by Austin Huguenard on 3/3/25.
//

import SwiftUI

struct BinaryFeedResults: View {
    @ObservedObject var post: BinaryPost
    @EnvironmentObject var userVM: UserFirebase

    var optionSelected: Int
    
    var body: some View {
//        let _ = print("CATEGORIES:", post.categories)
//        let _ = print("USERIDS",  post.responses
//            .filter { response in
//                userVM.user.friends.keys.contains(response.userId) &&
//                response.responseOption == post.responseOption1
//            }
//            .map { $0.userId })
//        let _ = print("USERIDS", post.responses
//            .map { $0.userId }
//            .filter { userVM.user.friends.keys.contains($0) })
        VStack {
            HStack {
                Spacer()
//                VStack {
//                    Text("NEXT")
//                        .foregroundStyle(.gray)
//                        .opacity(0.5)
//                    
//                    Image(systemName: "arrow.down")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 30, height: 30, alignment: .center)
//                        .foregroundStyle(.gray)
//                        .opacity(0.5)
//                }
                
                Spacer()
            }
            
            Spacer(minLength: 30.0)
            
            VStack(alignment: .leading) {
                ProfileUsernameDateView(dateTime: post.postDateAndTime, userId: post.userId)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(4)
                
                HStack {
                    if(post.categories.isEmpty) {
                        Text(verbatim: "No Categories Found")
                    } else {
                        ForEach(post.categories, id: \.self) { category in
                            Text(category.rawValue)
                                .font(.system(size: 12))
                                .fontWeight(.medium)
                                .padding(.top, 10)
                                .padding(.bottom, 10)
                                .padding(.leading, 8)
                                .padding(.trailing, 8)
                                .background(Color.categoryGray)
                                .cornerRadius(100)
                                .foregroundColor(.black)
                                .padding(.trailing, 10)
                                .lineLimit(1)
                        }
                    }

                }
                .frame(maxWidth: .infinity, alignment: .leading)
               
                
                HStack {
                    Text(post.question)
                        .padding(.top, 10)
                        .font(.system(size: 24))
                        .fontWeight(.semibold)
                    
                    Spacer()
                }
            }
            .padding(.horizontal)
            
            BinaryResultView(post: post, optionSelected: optionSelected)
                .padding(.top, 10)
                
            HStack {
                StackedProfiles(
                    userIds: post.responses
                        .filter { response in
                            userVM.user.friends.keys.contains(response.userId) &&
                            response.responseOption == post.responseOption1
                        }
                        .map { $0.userId }
                )
                Text("\(post.calculateResponses().reduce(0, +)) votes")
                    .foregroundColor(Color.blackGray)
                    .font(.system(size: 12))
                StackedProfiles(
                    userIds: post.responses
                        .filter { response in
                            userVM.user.friends.keys.contains(response.userId) &&
                            response.responseOption == post.responseOption1
                        }
                        .map { $0.userId }
                )
                
            }
            .padding(.top, 10)

  
                        
            withAnimation(.none, {
                CommentsView(comments: post.comments, postId: post.postId, responseOption1: post.responseOption1)
                    .onChange(of: post.comments) {old, new in
                            print("recognized  commentschanged")
                    }
                    .frame(maxWidth: .infinity)
                    .ignoresSafeArea()
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
    BinaryFeedResults(post: BinaryPost(postId: "903885747", userId: "coolguy", categories: [.sports(.nfl), .sports(.soccer), .entertainment(.tvShows), .entertainment(.movies)], postDateAndTime: Date(), question: "Insert controversial binary take right here in this box; yeah, incite some intereseting discourse", responseOption1: "bad", responseOption2: "good", sublabel1: "bad", sublabel2: "great"), optionSelected: 1)
}
