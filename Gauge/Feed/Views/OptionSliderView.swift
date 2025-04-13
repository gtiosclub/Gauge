//
//  SliderPost.swift
//  Gauge
//
//  Created by Kavya Adusumilli on 4/6/25.
//

import SwiftUI

struct OptionSliderView: View {
    private let numDots = 7
    @Binding var currentIndex: Int
    @Binding var dragAmount: CGSize
    
    // Local index that “commits” at drag start
    @State private var committedIndex: Int? = nil
    @State private var dragOffsetX: CGFloat = 0
    
    private let dotSize: CGFloat = 20
    private let maxExpandedSize: CGFloat = 50
    private let activeDotSize: CGFloat = 40
    
    var body: some View {
        Rectangle()
            .frame(height: 1)
            .foregroundStyle(Color.lightGray)
        
        GeometryReader { geo in
            let totalWidth = geo.size.width
            let spacing = (totalWidth - CGFloat(numDots)*dotSize) / CGFloat(numDots - 1)
            let centerY: CGFloat = 30

            ZStack(alignment: .leading) {
                // 1) Real-time index for display
                let baseIndex = committedIndex ?? currentIndex
                let draggedIndexEstimate = CGFloat(baseIndex) + dragOffsetX / (dotSize + spacing)
                // clamp to [0, numDots-1] to avoid wandering
                let safeIndex = max(0, min(CGFloat(numDots - 1), draggedIndexEstimate))
                let dotX = safeIndex * (dotSize + spacing)
                
                // 2) Draw background dots
                ForEach(0..<numDots, id: \.self) { index in
                    let baseX = CGFloat(index) * (dotSize + spacing)
                    let distance = abs(dotX - baseX)
                    let proximity = 1 - min(distance / (dotSize + spacing), 1)

                    let isCenter = (index == numDots / 2)
                    let fillColor = isCenter ? Color.gray.opacity(0.3) : Color.white
                    let currentSize = dotSize + (maxExpandedSize + (isCenter ? -10 : 0) - dotSize) * proximity

                    let shouldSolidify = proximity > 0.85
                    let strokeColor = isCenter ? .clear : Color.black.opacity(0.2 + 0.6 * proximity)
                    let dashSpacing = max(2, 4 - (proximity * 6))
                    let dash: [CGFloat] = isCenter ? [] : (shouldSolidify ? [] : [dashSpacing, dashSpacing])

                    Circle()
                        .stroke(strokeColor, style: StrokeStyle(lineWidth: 2, dash: dash))
                        .background(Circle().fill(fillColor))
                        .frame(width: currentSize, height: currentSize)
                        .position(x: baseX + dotSize/2, y: centerY)
                }
                
                let dragRange: CGFloat = 150
                let progress = min(max(-dragAmount.height / 100, 0), 1) // clamps between 0 and 1
                
                let interpolatedColor = currentIndex < 3 ? Color(
                    red: 0.0 + (237.0 / 255.0 - 0.0) * progress,
                    green: 0.0 + (56.0 / 255.0 - 0.0) * progress,
                    blue: 0.0 + (46.0 / 255.0 - 0.0) * progress
                )  : Color(
                    red: 0.0 + (52.0 / 255.0 - 0.0) * progress,
                    green: 0.0 + (199.0 / 255.0 - 0.0) * progress,
                    blue: 0.0 + (89.0 / 255.0 - 0.0) * progress
                )

                // 3) Draggable dot
                Circle()
                    .fill(interpolatedColor)
                    .frame(width: activeDotSize, height: activeDotSize)
                    .position(x: dotX + dotSize/2, y: centerY)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                // On first drag event, lock in our starting index
                                if committedIndex == nil {
                                    committedIndex = currentIndex
                                }
                                dragOffsetX = value.translation.width
                                
                                let finalFloat = CGFloat(committedIndex ?? currentIndex) + value.translation.width / (dotSize + spacing)
                                let finalIndex = Int(round(finalFloat))
                                let clampedIndex = max(0, min(numDots - 1, finalIndex))
                                
                                if clampedIndex != currentIndex {
                                    withAnimation() {
                                        currentIndex = clampedIndex  // update parent's binding
                                    }
                                }
                            }
                            .onEnded { value in
                                let finalFloat = CGFloat(committedIndex ?? currentIndex) + value.translation.width / (dotSize + spacing)
                                let finalIndex = Int(round(finalFloat))
                                let clampedIndex = max(0, min(numDots - 1, finalIndex))
                                
                                withAnimation(.easeOut(duration: 0.25)) {
                                    currentIndex = clampedIndex  // update parent's binding
                                }
                                // Reset local states
                                committedIndex = nil
                                dragOffsetX = 0
                            }
                    )

                // 4) Arrows
                let leftOpacity = Double(min(1, max(0, safeIndex / 1.5)))
                let rightOpacity = Double(min(1, max(0, (CGFloat(numDots-1) - safeIndex) / 1.5)))

                Image(systemName: "arrow.left")
                    .foregroundColor(.gray)
                    .opacity(leftOpacity)
                    .position(x: max(dotX + dotSize/2 - 36, dotSize/2), y: centerY)

                Image(systemName: "arrow.right")
                    .foregroundColor(.gray)
                    .opacity(rightOpacity)
                    .position(x: min(dotX + dotSize/2 + 36, totalWidth - dotSize/2), y: centerY)
            }
        }
        .frame(height: 60)
        .padding(.horizontal)
        
        Rectangle()
            .frame(height: 1)
            .foregroundStyle(Color.lightGray)
    }
}

#Preview {
    @Previewable @State var optionSelected = 3
    OptionSliderView(currentIndex: $optionSelected, dragAmount: .constant(CGSize(width: 40.0, height: 10.0)))
}
