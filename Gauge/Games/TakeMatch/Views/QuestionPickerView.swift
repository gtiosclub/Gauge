//
//  QuestionPickerView.swift
//  Gauge
//
//  Created by Akshat Shenoi on 3/5/25.
//

import SwiftUI

struct QuestionPickerView: View {
    @ObservedObject var mcManager: MCManager
    @State var questionOptions: [String]
    @State private var selectedQuestion: String? // Track the selected question
    @State var submitVote: Bool = false


    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Text("Vote which question the group should answer!")
                    .font(.title2)
                    .multilineTextAlignment(.center)
                ForEach(questionOptions, id: \.self) { question in
                    Button(action: {
                        // Set the selected question
                        selectedQuestion = question
                        // Optionally perform other actions when selecting a question
                    }) {
                        Text(question)
                            .font(.title2)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(selectedQuestion == question ? Color.black : Color(.secondarySystemFill))
                            )
                            .foregroundColor(.black)
                            .animation(.easeInOut, value: selectedQuestion)
                    }
                }
                Button(action: {
                    mcManager.voteForQuestion(selectedQuestion ?? "")
                    submitVote = true
                }) {
                    Text("Confirm")
                        .font(.title2)
                        .foregroundColor(.black)
                        .padding()
                        .background(Color(.secondarySystemFill))
                        .cornerRadius(12)
                        .scaleEffect(1.0)
                }
                .disabled(selectedQuestion == nil)
                .frame(maxWidth: 400)
                .buttonStyle(PressEffectButtonStyle())
            }
        }
        .padding()
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $submitVote) {
            VotingProgressView(mcManager: mcManager)
        }
    }
}

#Preview {
    QuestionPickerView(mcManager: MCManager(yourName: "test"), questionOptions: ["Hi", "Bye"])
}
