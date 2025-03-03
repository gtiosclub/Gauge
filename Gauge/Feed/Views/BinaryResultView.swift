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
            ZStack {
                //MARK: Background bars
                HStack(spacing: 0) {
                    // Left bar
                    Rectangle()
                        .fill(Color.gray)
                        .frame(width: geometry.size.width * fraction1)
                    
                    // Right bar
                    Rectangle()
                        .fill(Color.gray.opacity(0.25))
                        .frame(width: geometry.size.width * fraction2)
                }
                .frame(height: 40)
                .cornerRadius(8)
                
                //MARK: Overlay text
                HStack {
                    let textColor: [Color] = [fraction1 > 0.15 ? .white : .black, fraction2 < 0.15 ? .white : .black]
                    ///Adjust 0.15 to any threshold, working on a fix to make this modular based on text length
                    Text("\(Int(round(fraction1 * 100)))% \(post.responseOption1)")
                        .foregroundColor(textColor[0])
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 8)
                    
                    Text("\(Int(round(fraction2 * 100)))% \(post.responseOption2)")
                        .foregroundColor(textColor[1])
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.trailing, 8)
                }
                .frame(height: 40)
            }
        }
        .padding()
    }
}

#Preview {
    let r1 = 70
    let r2 = 100 - r1
    BinaryResultView(
        post: BinaryPost(
            postId: "sameer's post",
            userId: "Sameer",
            categories: [.arts(.painting)],
            postDateAndTime: Date(),
            question: "Picasso is the goat",
            responseOption1: "Facts 💯",
            responseOption2: "Nah 🤮",
            responseResult1: r1,
            responseResult2: r2,
            favoritedBy: ["sameer"]
        )
    )
}
