//
//  TakeMatchView.swift
//  Gauge
//
//  Created by Seohyun Park on 2/11/25.
//

import SwiftUI

struct TakeMatchView: View {
    @ObservedObject var mcManager: MCManager
    @ObservedObject  var gameSettings: TakeMatchSettingsVM
  
    @State private var currentScreen: Int = 1
    @State private var selectedTopic: String = ""

    @State private var question: String = "Loading..."
    @State private var responses: [String: String] = [:]
    @State private var guessedMatches: [String: String] = [:]
    @State private var players: [String] = ["Nikola", "Soy", "Dahyun", "Ethan", "Akshat"]
    @State private var inputText: String = ""
    
    var body: some View {
        VStack {
            switch currentScreen {
            case 1:
                QuestionView(mcManager: mcManager, question: question, inputText: $inputText) {
                //QuestionView(question: gameSettings.question, inputText: $inputText) {
                    responses[players[responses.count]] = inputText
                    inputText = ""
                    if responses.count == players.count {
                        currentScreen = 2
                    }
                }
            case 2:
                MatchingView(mcManager: mcManager, responses: Array(responses.values), playerPictures: players, guessedMatches: $guessedMatches) {
                    currentScreen = 3
                }
            case 3:
                ResultsView(responses: responses, guessedMatches: guessedMatches) {
                    responses = [:]
                    guessedMatches = [:]
                    currentScreen = 1
                    return true
                }
            default:
                Text("Invalid screen")
            }

        }
        .padding()
    }
}

#Preview {
    TakeMatchView(mcManager: MCManager(yourName: "test"))
    //TakeMatchView(gameSettings: TakeMatchSettingsVM())
}
