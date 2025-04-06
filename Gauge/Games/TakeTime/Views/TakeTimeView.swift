//
//  TakeTimeView.swift
//  Gauge
//
//  Created by Dahyun on 3/26/25.
//

import SwiftUI

struct TakeTimeView: View {
    @EnvironmentObject var scheduler: Scheduler

    var body: some View {
        VStack {
            Text("Take Time!")
                .font(.largeTitle)
                .padding()
            
            Text("Random Hot Take")
                .padding()
            
            Button(action: {
                scheduler.restoreUserState()
            }) {
                Text("Dismiss & Return")
                    .font(.title2)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
    }
}
