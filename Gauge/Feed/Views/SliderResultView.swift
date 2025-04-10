//
//  SliderResultView.swift
//  Gauge
//
//  Created by Sameer Arora on 4/9/25.
//

import SwiftUI


struct SliderResultView: View {
    @ObservedObject var post: SliderPost
    let optionSelected: Int
    
    var body: some View {
        // Avoid division by zero
        let total = max(post.calculateResponses().reduce(0, +), 1)
        let percent1 = Int(round(Double(post.calculateResponses()[0]) / Double(total) * 100))
        let percent2 = Int(round(Double(post.calculateResponses()[1]) / Double(total) * 100))
        let percent3 = Int(round(Double(post.calculateResponses()[2]) / Double(total) * 100))
        let percent4 = Int(round(Double(post.calculateResponses()[3]) / Double(total) * 100))
        let percent5 = Int(round(Double(post.calculateResponses()[4]) / Double(total) * 100))
        let percent6 = Int(round(Double(post.calculateResponses()[5]) / Double(total) * 100))
        
        GeometryReader { geometry in
            VStack {
                HStack(spacing: 0) {
                    ZStack(alignment: .leading) {
                        HStack(spacing: 0.0) {
                            CustomRoundedRectangle(topLeft: 10.0, topRight: percent1 == 100 ? 10.0 : 0.0, bottomRight: percent1 == 100 ? 10.0 : 0.0, bottomLeft: 10.0)
                                .stroke(optionSelected == 1 ? Color.darkRed : Color.lightGray, lineWidth: 1.0)
                                .fill(optionSelected == 1 ? .lightRed : percent1 == 0 ? Color.lightGreen : Color.lightGray)
                                .opacity(percent1 == 0 ? 0.0 : 1.0)
                                .frame(width: geometry.size.width * Double(percent1) / 100.0, height: 38.0)
                                .padding(.leading, 1)
                                .zIndex(optionSelected == 1 ? 4 : 0)
                            
                            CustomRoundedRectangle(topLeft: (percent2 == 100 ? 10.0 : 0.0), topRight: 10.0, bottomRight: 10.0, bottomLeft: (percent2 == 100 ? 10.0 : 0.0))
                                .stroke(optionSelected == 2 ? Color.darkGreen : Color.lightGray, lineWidth: 1.0)
                                .fill(optionSelected == 2 ? .lightGreen : percent2 == 0 ? Color.lightRed : Color.lightGray)
                                .opacity(percent2 == 0 ? 0.0 : 1.0)
                                .frame(width: geometry.size.width * Double(percent2) / 100.0, height: 38.0)
                                .padding(.trailing, 1)
                        }
                        
                    }
                }
                .frame(height: 40)
            }
            .frame(width: min(geometry.size.width, UIScreen.main.bounds.width), height: 40)
        }
        .frame(width: UIScreen.main.bounds.width - 30, height: 50)
    }
}

#Preview {
    SliderResultView(
        post: SliderPost(
            postId: "1",
            userId: "2lCFmL9FRjhY1v1NMogD5H6YuMV2",
            categories: [.arts(.painting)],
            postDateAndTime: Date(),
            question: "Picasso is the goat",
            lowerBoundLabel: "YES",
            upperBoundLabel: "NO",
            lowerBoundValue: 1.0,
            upperBoundValue: 6.0
            ),
        optionSelected: 3
    )
}
