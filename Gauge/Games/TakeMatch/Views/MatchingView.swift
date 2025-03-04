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
    @State private var hoveredResponse: String? = nil
    @State private var selectedImage: String? = nil

    var onSubmit: () -> Void

    var body: some View {
        VStack {
            Text("Match").font(.largeTitle.bold())
            HStack {
                ForEach(playerPictures, id: \.self) { imageName in
                    Image("TestProfile")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                        .shadow(radius: 1.5, x: 1.5, y: 1.5)
                        .foregroundColor(.yellow)
                        .scaleEffect(isDragging && selectedImage == imageName ? 1.2 : 1.0)
                        .opacity(isDragging && selectedImage == imageName ? 0.8 : 1.0)
                        .offset(x: lastPosition.width + dragOffset.width,
                                y: lastPosition.height + dragOffset.height)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        dragOffset = value.translation
                                        isDragging = true
                                        selectedImage = imageName

                                        let dragPosition = CGPoint(
                                            x: value.location.x + lastPosition.width,
                                            y: value.location.y + lastPosition.height
                                        )
                                        hoveredResponse = responseAtPosition(dragPosition)
                                    }
                                }
                                .onEnded { value in
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        lastPosition.width += dragOffset.width
                                        lastPosition.height += dragOffset.height
                                        dragOffset = .zero
                                        isDragging = false

                                        if let hoveredResponse = hoveredResponse, let selectedImage = selectedImage {
                                            guessedMatches[selectedImage] = hoveredResponse
                                        }

                                        hoveredResponse = nil
                                        selectedImage = nil
                                    }
                                }
                        )
                }
            }
            .zIndex(1)
            ZStack {
                VStack(spacing: 12) {
                    ForEach(responses, id: \.self) { response in
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(hoveredResponse == response ? Color.green : Color.gray)
                                .shadow(radius: 1.5, x: 1.5, y: 1.5)
                                .frame(height: 100)
                            Text(response)
                                .font(.title)
                        }
                        .background(GeometryReader { geometry in
                            Color.clear
                                .onAppear {
                                    responseFrames[response] = geometry.frame(in: .global)
                                }
                        })
                    }
                    Spacer()
                }
                .padding(.vertical)
            }
            .padding(.horizontal)
            Spacer()
        }
    }

    @State private var responseFrames: [String: CGRect] = [:]

    private func responseAtPosition(_ position: CGPoint) -> String? {
        for (response, frame) in responseFrames {
            if frame.contains(position) {
                return response
            }
        }
        return nil
    }
}

#Preview {
    MatchingView(responses: ["Pizza", "Hamburgers", "Fried Chicken", "Ice Cream"], playerPictures: ["TestProfile"], guessedMatches: .constant([:]), onSubmit: { })
}
