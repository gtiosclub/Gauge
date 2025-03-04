//
//  ResultsView.swift
//  Gauge
//
//  Created by Seohyun Park on 2/11/25.
//

import SwiftUI

struct ResultsView: View {
    var responses: [String: String]
    var guessedMatches: [String: String]
    var onRestart: () -> Bool
    @State var navigateToHome = false
    
    var body: some View {
        VStack {
            Text("Results").font(.title)
            List(responses.keys.sorted(), id: \..self) { player in
                HStack {
                    Text("\(player): \(responses[player] ?? "")")
                    Spacer()
                    Text(guessedMatches[player] == responses[player] ? "✅" : "❌")
                }
            }
            Button(action: {navigateToHome = onRestart()}) {
                Text("Again?")
            }
        }
        .navigationBarBackButtonHidden()
        .navigationDestination(isPresented: $navigateToHome) {
            GamesHome()
        }
    }
}


#Preview {
    ResultsView(responses: ["Player": "Answer"], guessedMatches: ["Answer": "Player"], onRestart: { return false })
}
