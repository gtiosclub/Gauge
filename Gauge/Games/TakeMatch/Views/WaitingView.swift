//
//  WaitingView.swift
//  Gauge
//
//  Created by Nikola Cao on 2/27/25.
//

import SwiftUI

struct WaitingView: View {
    @ObservedObject var mcManager: MCManager
    var responses: [String: String] {
        Dictionary(uniqueKeysWithValues: mcManager.takeMatchAnswers.map { ($0.sender, $0.text) })
        }
    var expectedCount: Int
    
    @State var guessedMatches: [String:String] = [:]
    @State var navigateToResults = false
    
    @Environment(\.dismiss) private var dismiss

    var voteProgress: Double {
        return Double(responses.count) / Double(mcManager.session.connectedPeers.count + 1)
    }


    var body: some View {
        VStack {
            Text("Are you excited to see how well your friends know you?")
                .font(.title2)
                .multilineTextAlignment(.center)
                .padding()
            ProgressView("Waiting...")
                .progressViewStyle(CircularProgressViewStyle())
                .padding()

            ProgressView(value: voteProgress, total: 1.0)
                .progressViewStyle(LinearProgressViewStyle())
                .padding()

            Text("\(responses.count)/\(mcManager.session.connectedPeers.count + 1)")

            var _ = print(responses)
            
        }
        .onChange(of: responses.count) { newCount, _ in
            
            print(newCount)
            if newCount >= expectedCount {
                navigateToResults = true
            }
        }
        .navigationDestination(isPresented: $navigateToResults) {
            let filteredResponses = responses.filter { $0.key != mcManager.username }
            MatchingView(mcManager: mcManager, responses: Array(filteredResponses.values), playerPictures: Array(filteredResponses.keys), guessedMatches: $guessedMatches, onSubmit: { })
        }
        .navigationBarBackButtonHidden()
        
    }
}



#Preview {
    WaitingView(mcManager: MCManager(yourName: "test"), expectedCount: 4)
}
