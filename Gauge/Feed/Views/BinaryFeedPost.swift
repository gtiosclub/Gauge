//
//  BinaryFeedPost.swift
//  Gauge
//
//  Created by HB on 2/27/25.
//

import SwiftUI

struct BinaryFeedPost: View {
    @EnvironmentObject var postVM: PostFirebase
    @EnvironmentObject var userVM: UserFirebase
    
    let post: BinaryPost
    
    var body: some View {
        VStack(alignment: .leading) {
            
            //ProfilePhoto + username + days since posted
            HStack{
                profileImage
                Text(post.userId)
                    .bold()
                    .font(.system(size: 16))
                    .padding(.leading, 10)
                
                Text("•   \(DateConverter.timeAgo(from: post.postDateAndTime))")
                    .font(.system(size: 13))
                    .padding(.leading, 5)
            }
            
            
            //Category Boxes
            ScrollView(.horizontal) {
                HStack {
                    let categories: [Category] = post.categories
                    
                    ForEach(categories, id: \.self) { category in
                        Text(category.rawValue)
                            .padding(.leading, 10)
                            .padding(.trailing, 10)
                            .font(.system(size: 14))
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.gray)
                                    .opacity(0.2)
                                    .frame(height: 32)
                            )
                            .padding(.top, 10)
                            .frame(minWidth: 40)
                            .fixedSize(horizontal: true, vertical: false)
                    }
                    
                    Spacer()
                }
                .padding(.bottom, 10)
            }
            .padding(.leading, 0)
            
            //Post Question
            Text(post.question)
                .padding(.top, 15)
                .bold()
                .font(.system(size: 35))
            
            // Response Option 1 & 2 with horizontal arrow in between
            HStack {
                Button(post.responseOption1){
                    post.responseResult1 += 1
                }
                .foregroundColor(.gray)
                .font(.system(size: 30))
//                .frame(minWidth: 120, alignment: .center)

                
                Spacer()
                
                Image(systemName: "arrow.left.and.right")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Button(post.responseOption2){
                    post.responseResult2 = post.responseResult2 + 1
                }
                .foregroundColor(.gray)
                .font(.system(size: 30))
//                    .frame(minWidth: 120, alignment: .center)
            }
            .padding(.top, 150)
            .padding(.horizontal)
            
            Spacer()
            
            Text("\(post.responseResult1 + post.responseResult2) votes")
                .foregroundColor(.gray)
                .scaledToFit()
                .frame(maxWidth: .infinity)
        }
        .padding(.top, 0)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.horizontal)
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
//
#Preview {
    BinaryFeedPost(post: BinaryPost(postId: "903885747", userId: "coolguy", categories: [.sports(.nfl),.sports(.soccer),.entertainment(.tvShows),.entertainment(.movies)], postDateAndTime: Date(), question: "Insert controversial binary take right here in this box; yeah, incite some intereseting discourse", responseOption1: "good", responseOption2: "bad")
    )
}

