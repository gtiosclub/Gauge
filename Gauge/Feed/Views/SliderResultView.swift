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
        let responses = post.calculateResponses()
        let total = max(responses.reduce(0, +), 1)
        let percentages = responses.map { Double($0) / Double(total) }
        
        let minHeight: CGFloat = 30  // minimum bar height even for 0%
        let maxHeight: CGFloat = 150

        // Find the min non-zero value to scale relative to it
        let maxPercent = percentages.max() ?? 1.0
        let normalizedHeights = percentages.map { percent in
            let scaled = percent / maxPercent
            return max(minHeight, scaled * maxHeight)
        }

        HStack(alignment: .bottom, spacing: 8) {
            ForEach(0..<percentages.count, id: \.self) { index in
                VStack(spacing: 6) {
                    // Bar with percentage text inside
                    ZStack(alignment: .bottom) {
                        let barHeight = normalizedHeights[index]
                        let percentText = String(format: "%.1f%%", percentages[index] * 100)
                        let isTooSmall = percentages[index] < 0.04

                        ZStack(alignment: .top) {
                            Rectangle()
                                .fill(colorForIndex(index, optionSelected))
                                .frame(height: barHeight)
                                .clipShape(RoundedRectangle(cornerRadius: 6))

                            if !isTooSmall {
                                Text(percentText)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(textForIndex(index, optionSelected: optionSelected))
                                    .padding(.top, 4)
                                    .padding(.horizontal, 2)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                            }
                        }

                        if isTooSmall {
                            Text(percentText)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(textForIndex(index, optionSelected: optionSelected))
                                .offset(y: -barHeight - 2)
                        }
                    }
                    .frame(height: maxHeight, alignment: .bottom)

                    // Dot
                    ZStack {
                        Circle()
                            .fill(index == optionSelected ? colorForIndex(index, optionSelected) : Color.white)
                            .overlay(Circle().stroke(Color.gray.opacity(0.4), lineWidth: 1))
                            .frame(width: 18, height: 18)
                    }
                    .frame(height: 20)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .overlay(
            GeometryReader { geo in
                let totalDots = percentages.count
                let spacing = geo.size.width / CGFloat(totalDots)
                let dotY = geo.size.height - 10.0  // Y-position of dots (adjust if needed)
                let lineLength: CGFloat = spacing * 0.4  // length of the short connector line

                ForEach(0..<totalDots - 1, id: \.self) { index in
                    let x1 = spacing * CGFloat(index) + spacing / 2
                    let x2 = spacing * CGFloat(index + 1) + spacing / 2
                    let midX = (x1 + x2) / 2

                    Path { path in
                        path.move(to: CGPoint(x: midX - lineLength / 2, y: dotY))
                        path.addLine(to: CGPoint(x: midX + lineLength / 2, y: dotY))
                    }
                    .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                }
            }
        )
        .padding(.horizontal)
        
        ///Text to see the responses and total
//        Text("\(responses) and \(total)")
//            .foregroundStyle(.black)
    }

    func colorForIndex(_ index: Int,_ optionSelected: Int) -> Color {
        let dark_condition = index == optionSelected
        switch index {
        case 0: return dark_condition ? Color.darkRed : Color.lightRed
        case 1: return dark_condition ? Color.darkOrange: Color.lightOrange
        case 2: return dark_condition ? Color.darkAmber : Color.lightAmber
        case 3: return dark_condition ? Color.darkYellow : Color.lightYellow
        case 4: return dark_condition ? Color.darkLime : Color.lightLime
        case 5: return dark_condition ? Color.darkGreen : Color.lightGreen
        default: return Color.gray
        }
    }
    
    func textForIndex(_ index: Int, optionSelected: Int) -> Color {
        if index == optionSelected {
            return Color.white
        }
        switch index {
        case 0: return Color.darkRed
        case 1: return Color.darkOrange
        case 2: return Color.darkAmber
        case 3: return Color.darkYellow
        case 4: return Color.darkLime
        case 5: return Color.darkGreen
        default: return Color.white
        }
    }
}

#Preview {
    let responses = [
        ///Option 1, 2/10 = 20%
        Response(responseId: "1", userId: "", responseOption: "1"),
        Response(responseId: "1", userId: "", responseOption: "1"),
        Response(responseId: "2", userId: "", responseOption: "1"),
        Response(responseId: "1", userId: "", responseOption: "1"),
        Response(responseId: "1", userId: "", responseOption: "1"),
        Response(responseId: "2", userId: "", responseOption: "1"),

        ///Option 2, 0/10 = 0%
        
        ///Option 3, 1/10 = 10%
        Response(responseId: "5", userId: "", responseOption: "3"),
        Response(responseId: "5", userId: "", responseOption: "3"),
        Response(responseId: "5", userId: "", responseOption: "3"),

        ///Option 4, 1/10 = 10%
        Response(responseId: "7", userId: "", responseOption: "4"),

        ///Option 4, 5/10 = 50%
        Response(responseId: "9", userId: "", responseOption: "5"),
        Response(responseId: "10", userId: "", responseOption: "5"),
        Response(responseId: "9", userId: "", responseOption: "5"),
        Response(responseId: "10", userId: "", responseOption: "5"),
        Response(responseId: "11", userId: "", responseOption: "5"),
        Response(responseId: "12", userId: "", responseOption: "5"),
        Response(responseId: "10", userId: "", responseOption: "5"),
        Response(responseId: "11", userId: "", responseOption: "5"),
        Response(responseId: "12", userId: "", responseOption: "5"),

        ///Option 4, 2/10 = 20%
        Response(responseId: "17", userId: "", responseOption: "6"),
        Response(responseId: "18", userId: "", responseOption: "6"),
        Response(responseId: "18", userId: "", responseOption: "2"),
        Response(responseId: "18", userId: "", responseOption: "3"),
        Response(responseId: "18", userId: "", responseOption: "4"),
        Response(responseId: "18", userId: "", responseOption: "6")
    ]

    let post = SliderPost(
        postId: "1",
        userId: "2lCFmL9FRjhY1v1NMogD5H6YuMV2",
        comments: [],
        responses: responses,
        categories: [.arts(.painting)],
        topics: [],
        postDateAndTime: Date(),
        question: "Picasso is the goat",
        lowerBoundLabel: "YES",
        upperBoundLabel: "NO",
        favoritedBy: []
    )

    SliderResultView(
        post: post,
        optionSelected: 4
    )
}
