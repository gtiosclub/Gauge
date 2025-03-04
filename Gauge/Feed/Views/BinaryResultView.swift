//
//  BinaryResultView.swift
//  Gauge
//
//  Created by Sameer Arora on 3/2/25.
//

import SwiftUI

struct BinaryResultView: View {
    let post: BinaryPost
    
    var body: some View {
        // Avoid division by zero
        let total = max(post.responseResult1 + post.responseResult2, 1)
        let fraction1 = Double(post.responseResult1) / Double(total)
        let fraction2 = Double(post.responseResult2) / Double(total)
        
        GeometryReader { geometry in
            HStack(spacing: 0) {
                // Left side
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray)
                    
                    Text("\(Int(round(Double(fraction1 * 100))))% \(post.responseOption1)")
                        .foregroundColor(.white)
                        .padding(.leading, 8)
                }
                .frame(width: geometry.size.width * fraction1)
                
                // Right side
                ZStack(alignment: .trailing) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.25))
                    
                    Text("\(Int(round(Double(fraction2 * 100))))% \(post.responseOption2)")
                        .foregroundColor(.black)
                        .padding(.trailing, 8)
                }
                .frame(width: geometry.size.width * fraction2)
            }
            .frame(height: 40)
            .cornerRadius(8)
        }
        .frame(height: 40)
        .padding()
    }
}

#Preview {
    BinaryResultView(
        post: BinaryPost(
            postId: "sameer's post",
            userId: "Sameer",
            categories: [.arts(.painting)],
            postDateAndTime: Date(),
            question: "Picasso is the goat",
            responseOption1: "Facts 💯",
            responseOption2: "Nah 🤮",
            responseResult1: 167, //167 people pressed Facts
            responseResult2: 83,  //83 people pressed Nah
            favoritedBy: ["sameer"]
        )
    )
}
