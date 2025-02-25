//
//  TakeMatchMatchingView.swift
//  Gauge
//
//  Created by Seohyun Park on 2/11/25.
//

import SwiftUI

struct MatchingView: View {
    var responses: [String]
    var playerPictures: [String]
    @Binding var guessedMatches: [String: String]

    @State private var dragOffset = CGSize.zero
    @State private var lastPosition = CGSize.zero
    @State private var isDragging = false
    @State private var hoveredResponse: String? = nil // Track hovered response

    var onSubmit: () -> Void
    var body: some View {
        VStack {
            Text("Match").font(.largeTitle.bold())
            ZStack {
                Rectangle()
                    .foregroundColor(Color(.secondarySystemFill))
                ZStack {
                    VStack(spacing: 12) {
                        ForEach(responses, id: \.self) { response in
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white)
                                        .shadow(radius: 1.5, x: 1.5, y: 1.5)
                                    Text(response)
                                        .font(.title)
                                }
                            }
                        Spacer()
                    }
                    .padding(.vertical)
                }.padding(.horizontal)
            }
            Spacer()
            ForEach(playerPictures, id: \.self) { imageName in
                Image("TestProfile")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
                    .shadow(radius: 1.5, x: 1.5, y: 1.5)
                    .foregroundColor(.yellow)
                    .scaleEffect(isDragging ? 1.2 : 1.0)
                    .opacity(isDragging ? 0.8 : 1.0)
                    .offset(x: lastPosition.width + dragOffset.width,
                            y: lastPosition.height + dragOffset.height)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    dragOffset = value.translation
                                    isDragging = true
                                }
                            }
                            .onEnded { value in
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    lastPosition.width += dragOffset.width
                                    lastPosition.height += dragOffset.height
                                    dragOffset = .zero
                                    isDragging = false
                                }
                            }
                    )
            }
        }
    }
}
#Preview {
    MatchingView(responses: ["Pizza", "Hamburgers", "Fried Chicken", "Ice Cream"], playerPictures: ["TestProfile"], guessedMatches: .constant([:]), onSubmit: { })
}
