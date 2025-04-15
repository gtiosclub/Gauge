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
        let percent1d = Double(post.calculateResponses()[0]) / Double(total) * 100
        let percent2d = Double(post.calculateResponses()[1]) / Double(total) * 100
        
        GeometryReader { geometry in
            VStack {
                HStack(spacing: 0) {
                    ZStack(alignment: .leading) {
                        HStack(spacing: 0.0) {
                            CustomRoundedRectangle(topLeft: 10.0, topRight: percent1 == 100 ? 10.0 : 0.0, bottomRight: percent1 == 100 ? 10.0 : 0.0, bottomLeft: 10.0)
                                .stroke(optionSelected == 2 ? Color.darkRed.opacity(0.3) : Color.darkRed, lineWidth: 1.0)
                                .fill(optionSelected == 1 ? Color.darkRed : percent1 == 0 ? Color.darkGreen.opacity(0.2) : Color.darkRed.opacity(0.1))
                                .opacity(percent1 == 0 ? 0.0 : 1.0)
                                .frame(width: geometry.size.width * Double(percent1) / 100.0, height: 60.0)
                                .padding(.leading, 1)
                                .zIndex(optionSelected == 1 ? 4 : 0)
                            
                            CustomRoundedRectangle(topLeft: (percent2 == 100 ? 10.0 : 0.0), topRight: 10.0, bottomRight: 10.0, bottomLeft: (percent2 == 100 ? 10.0 : 0.0))
                                .stroke(optionSelected == 1 ? Color.darkGreen.opacity(0.3) : Color.darkGreen, lineWidth: 1.0)
                                .fill(optionSelected == 2 ? Color.darkGreen : percent2 == 0 ? Color.darkRed.opacity(0.2) : Color.darkGreen.opacity(0.1))
                                .opacity(percent2 == 0 ? 0.0 : 1.0)
                                .frame(width: geometry.size.width * Double(percent2) / 100.0, height: 60.0)
                                .padding(.trailing, 1)
                        }
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("\(post.responseOption1)")
                                    .foregroundColor(optionSelected == 1 ? .white : (percent2 > 85 ? .white : .darkRed))
                                    .fontWeight(optionSelected == 1 ? .bold : .regular)
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.80)
                                
                                Text(String(format: "%.1f%%", percent1d))
                                    .foregroundColor(optionSelected == 1 ? .white : (percent2 > 85 ? .white : .darkRed))
                                    .fontWeight(optionSelected == 1 ? .bold : .regular)
                            }
                            .padding(.leading, 10)
                            
                            Spacer()
                            
                            VStack(alignment: .trailing) {
                                Text("\(post.responseOption2)")
                                    .foregroundColor(optionSelected == 2 ? .white : (percent1 > 85 ? .black : .darkGreen))
                                    .fontWeight(optionSelected == 2 ? .bold : .regular)
                                    .multilineTextAlignment(.trailing)
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.80)
                                
                                Text(String(format: "%.1f%%", percent2d))
                                    .foregroundColor(optionSelected == 2 ? .white : (percent1 > 85 ? .black : .darkGreen))
                                    .fontWeight(optionSelected == 2 ? .bold : .regular)
                            }
                            .padding(.trailing, 10)
                        }
                    }
                }
                //                 .frame(height: 60)
            }
            .frame(width: min(geometry.size.width, UIScreen.main.bounds.width), height: 60)
        }
        //         .frame(width: UIScreen.main.bounds.width, height: 60)
    }
}
 
struct CustomRoundedRectangle: Shape {
    var topLeft: CGFloat
    var topRight: CGFloat
    var bottomRight: CGFloat
    var bottomLeft: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var corners: UIRectCorner = []
        
        if topLeft > 0 { corners.insert(.topLeft) }
        if topRight > 0 { corners.insert(.topRight) }
        if bottomRight > 0 { corners.insert(.bottomRight) }
        if bottomLeft > 0 { corners.insert(.bottomLeft) }
        
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: max(topLeft, topRight, bottomLeft, bottomRight), height: max(topLeft, topRight, bottomLeft, bottomRight))
        )
        return Path(path.cgPath)
    }
}
 
#Preview {
    BinaryResultView(
        post: BinaryPost(
            postId: "sameer's post",
            userId: "Sameer",
            responses: [
                Response(responseId: "1", userId: "1", responseOption: "Yes"),
                Response(responseId: "1", userId: "1", responseOption: "No"),
                Response(responseId: "1", userId: "1", responseOption: "No"),
                Response(responseId: "1", userId: "1", responseOption: "Yes"),
                Response(responseId: "1", userId: "1", responseOption: "No"),
                Response(responseId: "1", userId: "1", responseOption: "No"),
                Response(responseId: "1", userId: "1", responseOption: "No"),
                Response(responseId: "1", userId: "1", responseOption: "No"),
                Response(responseId: "1", userId: "1", responseOption: "No"),
                Response(responseId: "1", userId: "1", responseOption: "No"),
                Response(responseId: "2", userId: "2", responseOption: "No")
            ],
            categories: [.arts(.painting)],
            topics: ["art", "picasso"],
            postDateAndTime: Date(),
            question: "Picasso is the goat",
            responseOption1: "Yes",
            responseOption2: "No",
            sublabel1: "Facts 💯",
            sublabel2: "Nah 🤮",
            favoritedBy: ["sameer"]
        ),
        optionSelected: 2
    )
}
