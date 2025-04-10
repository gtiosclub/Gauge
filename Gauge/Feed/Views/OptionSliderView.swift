//
//  SliderPost.swift
//  Gauge
//
//  Created by Kavya Adusumilli on 4/6/25.
//


//WORKING FUNCTIONALITY
import SwiftUI

struct OptionSliderView: View {
    private let numDots = 7
    private let dots = [0, 1, 2, 3, 4, 5, 6]
    @State private var currentIndex: Int = 3
    @GestureState private var dragOffset: CGFloat = 0.0
    
    //constants
    private let dotSize: CGFloat = 20
    private let activeDotSize: CGFloat = 40
    private let maxExpandedSize: CGFloat = 32
    private let arrowSpacing: CGFloat = 36
    
    // Computed properties
    private var activePosition: CGFloat {
        let totalWidth = UIScreen.main.bounds.width - 40 // Account for padding
        let stepWidth = totalWidth / CGFloat(numDots - 1)
        return stepWidth * CGFloat(currentIndex) + dragOffset
    }

    var body: some View {
        GeometryReader { geo in
            let totalWidth = geo.size.width
            let stepWidth = totalWidth / CGFloat(numDots - 1)
            let dotPosition = stepWidth * CGFloat(currentIndex) + dragOffset
            
            ZStack {
                // Background track with interactive dots
                HStack(spacing: 0) {
                    ForEach(dots, id: \.self) { index in
                        let dotCenter = stepWidth * CGFloat(index)
                        let distance = abs(dotPosition - dotCenter)
                        let proximity = 1 - min(distance / (stepWidth * 0.8), 1)
                        
                        // Calculate dot properties based on proximity to active dot
                        let currentSize = dotSize + (maxExpandedSize - dotSize) * proximity
                        let isSolid = distance < (stepWidth * 0.6) // Threshold for becoming solid
                        
                        Circle()
                            .stroke(isSolid ? Color.black : Color.gray.opacity(0.5),
                                    style: StrokeStyle(lineWidth: 2, dash: isSolid ? [] : [2]))
                            .background(Circle().fill(isSolid ? Color.gray.opacity(0.3) : Color.white))
                            .frame(width: currentSize, height: currentSize)
                            .animation(.easeOut(duration: 0.2), value: distance)
                        
                        if index != dots.last {
                            Spacer()
                        }
                    }
                }
                
                // Active dot (black circle)
                Circle()
                    .fill(Color.black)
                    .frame(width: activeDotSize, height: activeDotSize)
                    .position(x: dotPosition, y: 30)
                    .gesture(
                        DragGesture()
                            .updating($dragOffset) { value, state, _ in
                                state = value.translation.width
                            }
                            .onEnded { value in
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    let stepChange = Int(round(value.translation.width / stepWidth))
                                    currentIndex = min(max(currentIndex + stepChange, 0), numDots - 1)
                                }
                            }
                    )
                
                // Arrows
                if currentIndex > 0 {
                    Image(systemName: "arrow.left")
                        .foregroundColor(.gray)
                        .position(
                            x: max(dotPosition - arrowSpacing, activeDotSize/2),
                            y: 30
                        )
                }
                
                if currentIndex < numDots - 1 {
                    Image(systemName: "arrow.right")
                        .foregroundColor(.gray)
                        .position(
                            x: min(dotPosition + arrowSpacing, totalWidth - activeDotSize/2),
                            y: 30
                        )
                }
            }
        }
        .frame(height: 60)
        .padding(.horizontal, 20)
    }
}

#Preview {
    OptionSliderView()
}
