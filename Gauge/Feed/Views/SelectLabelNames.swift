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
    
    let slidingOptions: [SlidingOption]
    
    @Binding var selectedIndex: Int?
    @Binding var stepCompleted: Bool

    var body: some View {
        VStack(spacing: 0) {
            ForEach(slidingOptions.indices, id: \.self) { index in
                BinaryOptionView(
                    leftOption: slidingOptions[index].left,
                    rightOption: slidingOptions[index].right,
                    isSelected: selectedIndex == index,
                    action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedIndex = index
                            stepCompleted = true
                        }
                    }
                )
                if index != slidingOptions.count - 1 {
                    Divider()
                }
            }
        }
        .padding()
        .onAppear {
            stepCompleted = selectedIndex != nil
        }
    }
}

struct BinaryOptionView: View {
    let leftOption: String
    let rightOption: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        ZStack {
            HStack {
                Text(leftOption)
                    .font(.title)
                    .foregroundColor(isSelected ? .black : .gray.opacity(0.8))
                    .fontWeight(.medium)
                
                Spacer()
    
                Text(rightOption)
                    .font(.title)
                    .foregroundColor(isSelected ? .black : .gray.opacity(0.8))
                    .fontWeight(.medium)
                
                
            }
            .padding(.vertical, 20)
            .padding(.horizontal, isSelected ? 20 : 0)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(isSelected ? Color.gray.opacity(0.08) : Color.clear)
                    .shadow(radius: isSelected ? 5 : 0)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(isSelected ? Color.gray : Color.clear, lineWidth: 1)
            )
            .contentShape(Rectangle())
            .onTapGesture(perform: action)
            
            Image(systemName: "arrow.left.and.right")
                .resizable()
                .foregroundColor(isSelected ? .black : .gray)
                .frame(width: 30, height: 20)
        }
    }
}




#Preview {
    SelectLabelNames(slidingOptions: [
        .init(left: "No", right: "Yes"),
        .init(left: "Hate", right: "Love"),
        .init(left: "Cringe", right: "Cool")
    ], selectedIndex: .constant(0), stepCompleted: .constant(false))
}
