//
//  QuestionView.swift
//  Gauge
//
//  Created by Seohyun Park on 2/11/25.
//

import SwiftUI

struct QuestionView: View {
    @ObservedObject var mcManager: MCManager
    var question: String
    @Binding var inputText: String
    var onSubmit: () -> Void
    @State var guessedMatches: [String: String] = [:]
    @State var submitAnswer = false

    var body: some View {
        VStack(spacing: 30) {
            Text(question).font(.title)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.secondarySystemFill))
                )
            TextField("", text: $inputText, axis: .vertical)
                .font(.title)
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .multilineTextAlignment(.leading)
                .lineLimit(2, reservesSpace: true)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .stroke(Color.black)
                )
            Button(action: {
                onSubmit()
                submitAnswer = true

            }) {
                Text("Submit")
                    .font(.title2)
                    .foregroundColor(.black)
                    .padding()
                    .background(Color(.secondarySystemFill))
                    .cornerRadius(12)
                    .scaleEffect(1.0)
            }
            .frame(maxWidth: 400)
            .buttonStyle(PressEffectButtonStyle())

        }
        .padding()
        .navigationTitle(Text("Take Match"))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $submitAnswer) {

            let responses = Dictionary(
                uniqueKeysWithValues: mcManager.takeMatchAnswers.map {
                    ($0.sender, $0.text)
                })
            if mcManager.connectedPeers.count + 1 <= responses.count {
                let filteredResponses = responses.filter {
                    $0.key != mcManager.username
                }
                MatchingView(
                    mcManager: mcManager,
                    responses: Array(filteredResponses.values),
                    playerPictures: Array(filteredResponses.keys),
                    guessedMatches: $guessedMatches, onSubmit: {})
            } else {

                WaitingView(
                    mcManager: mcManager,
                    expectedCount: mcManager.connectedPeers.count)
            }

        }
        .navigationBarBackButtonHidden()

    }
}

#Preview {
    QuestionView(
        mcManager: MCManager(yourName: "test"),
        question: "Some question about this person's preferences",
        inputText: .constant(""), onSubmit: {})
}

struct PressEffectButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(
                .easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
