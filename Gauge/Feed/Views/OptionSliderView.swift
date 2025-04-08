//
//  SliderPost.swift
//  Gauge
//
//  Created by Kavya Adusumilli on 4/6/25.
//

import SwiftUI

struct OptionSliderView: View {
    // options
    let labels = ["Hell no", "Nah", "Sure", "Yeah duh"]
    @State private var currentIndex: Int = 2
    @GestureState private var dragOffset: CGFloat = 0.0

    var body: some View {
        VStack(spacing: 40) {
            Text(labels[currentIndex])
                .font(.title)
                .fontWeight(.bold)
                .padding(.bottom, 20)

            GeometryReader { geo in
                let totalWidth = geo.size.width
                let stepWidth = totalWidth / CGFloat(labels.count - 1)

                ZStack {
                    HStack(spacing: stepWidth - 20) {
                        ForEach(labels.indices, id: \.self) { index in
                            Circle()
                                .strokeBorder(index == currentIndex ? Color.black : Color.gray.opacity(0.5), lineWidth: 2)
                                .background(Circle().fill(index == currentIndex ? Color.gray.opacity(0.3) : Color.white))
                                .frame(width: 20, height: 20)
                        }
                    }

                    // circle w/ arrows
                    HStack(spacing: 8) {
                        if currentIndex > 0 {
                            Image(systemName: "arrow.left")
                                .foregroundColor(.white)
                        }

                        Circle()
                            .fill(Color.black)
                            .frame(width: 40, height: 40)

                        if currentIndex < labels.count - 1 {
                            Image(systemName: "arrow.right")
                                .foregroundColor(.white)
                        }
                    }
                    .offset(x: stepWidth * CGFloat(currentIndex) + dragOffset - 20)
                    .gesture(
                        DragGesture()
                            .updating($dragOffset) { value, state, _ in
                                state = value.translation.width
                            }
                            .onEnded { value in
                                let stepChange = Int(round(value.translation.width / stepWidth))
                                currentIndex = min(max(currentIndex + stepChange, 0), labels.count - 1)
                            }
                    )
                    .animation(.easeInOut, value: currentIndex)
                }
            }
            .frame(height: 60)
        }
        .padding()
    }
}

#Preview {
    OptionSliderView()
}
