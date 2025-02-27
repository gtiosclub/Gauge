//
//  TakeMatchView.swift
//  Gauge
//
//  Created by Seohyun Park on 2/11/25.
//

import SwiftUI

struct TakeMatchView: View {
    @State private var currentScreen: Int = 1
    @State private var question: String = "What's the most overrated food?"
    @State private var responses: [String: String] = [:]
    @State private var guessedMatches: [String: String] = [:]
    @State private var players: [String] = ["Nikola", "Soy", "Dahyun", "Ethan", "Akshat"]
    @State private var inputText: String = ""
    
    var body: some View {
        VStack {
            switch currentScreen {
            case 1:
                QuestionView(question: question, inputText: $inputText) {
                    responses[players[responses.count]] = inputText
                    inputText = ""
                    if responses.count == players.count {
                        currentScreen = 2
                    }
                }
            case 2:
                MatchingView(responses: Array(responses.values), playerPictures: players, guessedMatches: $guessedMatches) {
                    currentScreen = 3
                }
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
        .padding()
    }
}

#Preview {
    TakeMatchView()
}
