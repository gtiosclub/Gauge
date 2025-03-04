//
//  TakeMatchView.swift
//  Gauge
//
//  Created by Seohyun Park on 2/11/25.
//
import SwiftUI
import Algorithms

struct TakeMatchView: View {
    @State private var currentScreen: Int = 1
    @State private var question: String = "What's the most overrated food?"
    @State private var responses: [String: String] = [:]
    @State private var guessedMatches: [String: String] = [:]
    @State private var players: [String] = ["Player1", "Player2", "Player3", "Player4"]
    @State private var inputText: String = ""

    // State for Untitled view
    @State private var iconBank: [String] = []
    @State private var responseGuesses: [String?] = []
    @State private var isTargeted: [Bool] = []

    var body: some View {
        VStack {
            switch currentScreen {
            case 1:
                QuestionView(question: question, inputText: $inputText) {
                    responses[players[responses.count]] = inputText
                    inputText = ""
                    if responses.count == players.count {
                        // Initialize state for Untitled view
                        iconBank = players
                        responseGuesses = Array(repeating: nil, count: players.count)
                        isTargeted = Array(repeating: false, count: players.count)
                        currentScreen = 2
                    }
                }
            case 2:
                // Extract responses in the correct order
                let responseValues = players.map { responses[$0] ?? "" }
                MatchView(
                    iconBank: $iconBank,
                    responseGuesses: $responseGuesses,
                    isTargeted: $isTargeted,
                    responses: responseValues, // Pass the actual responses
                    onSubmit: {
                        // Map responseGuesses to guessedMatches
                        for (index, player) in players.enumerated() {
                            if let guessedPlayer = responseGuesses[index] {
                                guessedMatches[player] = guessedPlayer
                            }
                        }
                        currentScreen = 3
                    }
                )
            case 3:
                ResultsView(responses: responses, guessedMatches: guessedMatches) {
                    responses = [:]
                    guessedMatches = [:]
                    currentScreen = 1
                }
            default:
                Text("Invalid screen")
            }
        }
    }
}



#Preview {
    TakeMatchView()
}
