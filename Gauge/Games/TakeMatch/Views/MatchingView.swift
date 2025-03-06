//
//  TakeMatchMatchingView.swift
//  Gauge
//
//  Created by Seohyun Park on 2/11/25.
//

import SwiftUI

struct MatchingView: View {
    @ObservedObject var mcManager: MCManager
    var responses: [String]
    var playerPictures: [String]
    @Binding var guessedMatches: [String: String]
    var matches: [String: String] {
        Dictionary(uniqueKeysWithValues: mcManager.takeMatchAnswers.map { ($0.sender, $0.text) })
        }

    @State private var dragOffset = CGSize.zero
    @State private var lastPosition = CGSize.zero
    @State private var isDragging = false
    @State private var hoveredResponse: String? = nil // Track hovered response

    @State var guesses: [String: String] = [:]
    @State var navigateToResults = false


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
//                                    Text(response)
//                                        .font(.title)
                                    AnswerDropView(answer: response, guessedMatches: $guesses)
                                }
                            }
                        Spacer()
                    }
                    .padding(.vertical)
                }.padding(.horizontal)
            }
            Spacer()
            Button(action: {
                onSubmit()
                navigateToResults = true
            }) {
                Text("submit")
            }
            
            Spacer()
            
            HStack {
                ForEach(Array(playerPictures.enumerated()), id: \.offset) { index, imageName in
                    VStack {
                        DraggableText(playerName: imageName)
//                        if (mcManager.connectedPeers.count > index) {
//                            var peer = mcManager.connectedPeers[index]
//                            Text(mcManager.discoveredPeers[peer]?.username ?? peer.displayName)
//                        } else {
//                            Text("Test\(index)")
//                        }
                        
                        Text(imageName)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden()
        .navigationDestination(isPresented: $navigateToResults) {
            
            let filteredResponses = matches.filter { $0.key != mcManager.username }
            ResultsView(
                responses: filteredResponses,
                guessedMatches: guesses,
                onRestart: {
                    return true
                }
            )
        }
    }
}
#Preview {
    MatchingView(mcManager: MCManager(yourName: "Test"), responses: ["Pizza", "Hamburgers", "Fried Chicken", "Ice Cream"], playerPictures: ["TestProfile", "TestProfile", "TestProfile"], guessedMatches: .constant([:]), onSubmit: { })
}


struct DraggableSticker: View {
    var imageName: String
    @State private var dragOffset: CGSize = .zero
    @State private var lastPosition: CGSize = .zero
    @State private var isDragging = false

    var body: some View {
        Image(imageName)
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

struct DraggableText: View {
    var playerName: String
    var body: some View {
        Text(playerName)
            .frame(width: 80, height: 80)
            .clipShape(Circle())
            .shadow(radius: 1.5, x: 1.5, y: 1.5)
            .foregroundColor(.yellow)
            .onDrag {
                let provider = NSItemProvider(object: playerName as NSString)
                return provider
            }
    }
}


struct AnswerDropView: View {
    var answer: String
    @Binding var guessedMatches: [String: String]
    
    var body: some View {
        Text(answer)
            .font(.title)
            .frame(maxWidth: .infinity, minHeight: 60)
            .background(Color.white)
            .onDrop(of: ["public.text"], isTargeted: nil) { providers in
                if let provider = providers.first {
                    provider.loadItem(forTypeIdentifier: "public.text", options: nil) { (data, error) in
                        if let data = data as? Data, let droppedName = String(data: data, encoding: .utf8) {
                            DispatchQueue.main.async {
                                // Map the dropped player's name to the answer.
                                guessedMatches[droppedName] = answer
                            }
                        }
                    }
                }
                return true
            }
    }
}
