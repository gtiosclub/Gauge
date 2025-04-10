//
//  BinaryResultView.swift
//  Gauge
//
//  Created by Sameer Arora on 3/2/25.
//

import SwiftUI

struct BinaryResultView: View {
    @ObservedObject var post: BinaryPost
    let optionSelected: Int
    
    var body: some View {
        // Avoid division by zero
        let total = max(post.calculateResponses().reduce(0, +), 1)
        let percent1 = Int(round(Double(post.calculateResponses()[0]) / Double(total) * 100))
        let percent2 = Int(round(Double(post.calculateResponses()[1]) / Double(total) * 100))
        
        GeometryReader { geometry in
            VStack(spacing: 12) {
                HStack(spacing: 0) {
                    // Left option bar (No)
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.red.opacity(0.15))
                            .frame(width: max(345 * Double(percent1) / 100.0, 0), height: 60)
                        Path { path in
                            let width = max(345 * Double(percent1) / 100.0, 0)
                            let height: CGFloat = 60
                            let cornerRadius: CGFloat = 12
                            
                            // Start at top-right (no corner radius here)
                            path.move(to: CGPoint(x: width, y: 0))
                            
                            // Draw to top-left with corner radius
                            path.addLine(to: CGPoint(x: cornerRadius, y: 0))
                            path.addArc(
                                center: CGPoint(x: cornerRadius, y: cornerRadius),
                                radius: cornerRadius,
                                startAngle: .degrees(270),
                                endAngle: .degrees(180),
                                clockwise: true
                            )
                            
                            // Draw to bottom-left with corner radius
                            path.addLine(to: CGPoint(x: 0, y: height - cornerRadius))
                            path.addArc(
                                center: CGPoint(x: cornerRadius, y: height - cornerRadius),
                                radius: cornerRadius,
                                startAngle: .degrees(180),
                                endAngle: .degrees(90),
                                clockwise: true
                            )
                            
                            // Draw to bottom-right (no corner radius here)
                            path.addLine(to: CGPoint(x: width, y: height))
                            
                            path.addLine(to: CGPoint(x: width, y: 0))
                        }
                        .stroke(Color.red, lineWidth: 1)
                        .frame(width: max(345 * Double(percent1) / 100.0, 0), height: 60)
                        
                        VStack (alignment: .leading){
                            
                            Text(post.responseOption1)
                                .font(.system(size: 12))
                                .foregroundColor(.red)
                            Text("\(percent1)%")
                                .fontWeight(.bold)
                                .foregroundColor(.red)
                                .font(.system(size: 12))
                        }
                        .padding(.leading, 12)
                        .frame(width: 345 * Double(percent1) / 100.0, alignment: .leading)
                    }
                    
                    // Right option bar (Yes)
                    ZStack(alignment: .trailing) {
                        Rectangle()
                            .fill(Color.darkGreen)
                            .frame(width: max(345 * Double(percent2) / 100.0, 0), height: 60)
                        
                        VStack(alignment: .trailing) {
                            Text(post.responseOption2)
                                .fontWeight(.bold)
                                .font(.system(size: 12))
                                .foregroundColor(.white)
                            
                            Text("\(percent2)%")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .font(.system(size: 12))

                        }
                        .padding(.trailing, 12)
                        .frame(width: 345 * Double(percent2) / 100.0, alignment: .trailing)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .frame(height: 40)
                .padding(.bottom, 16)
            }
            .frame(width: UIScreen.main.bounds.width - 40, height: 50)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 60)
    }
}
#Preview {
    BinaryResultView(
        post: BinaryPost(
            postId: "sameer's post",
            userId: "Sameer",
            categories: [.arts(.painting)],
            topics: ["art", "picasso"], postDateAndTime: Date(),
            question: "Picasso is the goat",
            responseOption1: "Yes",
            responseOption2: "No",
            sublabel1: "Facts 💯",
            sublabel2: "Nah 🤮",
            favoritedBy: ["sameer"]
        ),
        optionSelected: 1
    )
}
