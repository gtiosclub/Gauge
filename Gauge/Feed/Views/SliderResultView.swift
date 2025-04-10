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

        HStack(alignment: .bottom, spacing: 8) {
            ForEach(0..<percentages.count, id: \.self) { index in
                VStack {
                    //Show text on top bar, if 0%
                    if percentages[index] == 0 {
                        Text(String(format: "%.1f%%", percentages[index] * 100))
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(textForIndex(index, optionSelected: optionSelected))
                            .padding(.top, 4)
                            .padding(.horizontal, 2)
                    }
                    ZStack(alignment: .top) {
                        Rectangle()
                            .fill(colorForIndex(index, optionSelected))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                        
                        //Show text within bar, if >0%
                        if percentages[index] > 0 {
                            Text(String(format: "%.1f%%", percentages[index] * 100))
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(textForIndex(index, optionSelected: optionSelected))
                                .padding(.top, 4)
                                .padding(.horizontal, 2)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)

                        }
                    }
                }
        
                .frame(
                    maxWidth: .infinity,
                    minHeight: 0,
                    maxHeight: Double(percentages[index] * 250)
                )
            }
        }
        .padding()
        
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

    return SliderResultView(
        post: post,
        optionSelected: 4
    )
}
