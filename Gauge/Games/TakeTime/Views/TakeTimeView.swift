//
//  TakeTimeView.swift
//  Gauge
//
//  Created by Dahyun on 3/26/25.
//

import SwiftUI

struct TakeTimeView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.orange, Color.red]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                Image(systemName: "hourglass")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.black.opacity(10))
                    .rotationEffect(.degrees(45))
                    

                Text("Take Time!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.black.opacity(10))
            }
        }
    }
}
