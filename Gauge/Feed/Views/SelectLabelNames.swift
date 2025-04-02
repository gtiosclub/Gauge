//
//  SelectLabelNames.swift
//  Gauge
//
//  Created by Yingqi Chen on 4/1/25.
//

import SwiftUI

struct SlidingOption {
    let left: String
    let right: String
}
struct SelectLabelNames: View {
    //when using the variable from BinaryPost, just use the resonseOption1 and responseOption2 and place it here
    let slidingOptions: [SlidingOption] = [
        .init(left: "No", right: "Yes"),
        .init(left: "Hate", right: "Love"),
        .init(left: "Cringe", right: "Cool")
    ]
    
    @State private var selectedIndex: Int? = nil

    var body: some View {
        VStack(spacing: 0) {
            ForEach(slidingOptions.indices, id: \.self) { index in
                SlideableArrowButton(
                    responseOption1: slidingOptions[index].left,
                    responseOption2: slidingOptions[index].right,
                    isSelected: $selectedIndex,
                    currentIndex: index
                )
                if index != slidingOptions.count - 1 {
                    Divider()
                }
            }
        }
        .padding()
    }
}

struct SlideableArrowButton: View {
    let responseOption1: String
    let responseOption2: String
    @Binding var isSelected: Int?
    let currentIndex: Int

    @State private var dragOffset: CGFloat = 0
    @State private var selectedOption: String? = nil
    //the threshold variable for how intelligence the button in the middle will listen for changing the chosen value when draging
    let threshold: CGFloat = 20

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                HStack {
                    Text(responseOption1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(responseOption2)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .padding()
                .background(isSelected == currentIndex ? Color.gray.opacity(0.2) : Color.clear)
                .cornerRadius(40)

                Image(systemName: "arrow.left.and.right")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
                    .padding(12)
                    .offset(x: dragOffset)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                dragOffset = value.translation.width
                            }
                            .onEnded { _ in
                                if dragOffset > threshold {
                                    selectedOption = responseOption2
                                    isSelected = currentIndex
                                    chosen(option: responseOption2)
                                } else if dragOffset < -threshold {
                                    selectedOption = responseOption1
                                    isSelected = currentIndex
                                    chosen(option: responseOption1)
                                }
                                withAnimation {
                                    dragOffset = 0
                                }
                            }
                    )
            }
            .frame(height: 80)
            .padding(.horizontal)
            
//            if let option = selectedOption {
//                Text("You chose: \(option)")
//                    .foregroundColor(.black)
//            }
        }
    }

    func chosen(option: String) {
        print("Chosen: \(option)")
    }
}


#Preview {
    SelectLabelNames()
}
