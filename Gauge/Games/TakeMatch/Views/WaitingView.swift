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
    
    @State var navigateToResults = false
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            
            Text("Waiting for players...")
                .font(.title2)
                .padding()
            
            var _ = print(responses)
            
        }
        .onChange(of: responses.count) { newCount, _ in
            
            print(newCount)
            if newCount >= expectedCount {
                navigateToResults = true
            }
        }
        .navigationDestination(isPresented: $navigateToResults) {
            ResultsView(
                responses: responses,
                guessedMatches: [:],
                onRestart: {
                    return true
                }
            )
        }
        .navigationBarBackButtonHidden()
        
    }
}



#Preview {
    WaitingView(mcManager: MCManager(yourName: "test"), expectedCount: 4)
}
