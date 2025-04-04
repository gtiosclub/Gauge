//
//  GenderSelectionView.swift
//  Gauge
//
//  Created by Anthony Le on 4/3/25.
//

import SwiftUI

struct GenderSelectionView: View {
    @State private var genderSelection: String = ""
    @State private var navigateToLocation: Bool = false
    let genderOptions = ["Male", "Female", "Other"]

    var body: some View {
        VStack(spacing: 0) {
            AboutYouProgressBar(progress: 1)
            
            ZStack {
                Text("About You")
                    .font(.system(size: 17, weight: .semibold))
            }
            .padding(.top, 12)
            .padding(.horizontal, 18)
            
            Spacer().frame(height: 30)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("What is your gender?")
                    .font(.title)
                    .bold()
                    .padding(.bottom, 20)

                Menu {
                    ForEach(genderOptions, id: \.self) { gender in
                        Button(action: {
                            genderSelection = gender
                        }) {
                            Text(gender)
                        }
                    }
                } label: {
                    HStack {
                        Text(genderSelection.isEmpty ? "Gender" : genderSelection)
                            .foregroundColor(genderSelection.isEmpty ? .gray : .black)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                    )
                }
            }
            .padding(.horizontal, 24)

            Spacer()

            Button(action: {
                navigateToLocation = true
            }) {
                HStack {
                    Spacer()
                    Text(genderSelection.isEmpty ? "Skip" : "Next")
                        .foregroundColor(.white)
                        .bold()
                    Image(systemName: "arrow.right")
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding()
                .background(Color.blue)
                .opacity(genderSelection.isEmpty ? 0.4 : 1.0)
                .cornerRadius(25)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 8)

            Spacer().frame(height: 0)
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $navigateToLocation) {
            LocationSelectionView()
        }
    }
}

struct AboutYouProgressBar: View {
    var progress: Int
    var steps: Int = 6
    var spacing: CGFloat = 8
    var barFraction: CGFloat =  3 / 4

    var body: some View {
        GeometryReader { geometry in
            let totalWidth = geometry.size.width * barFraction
            let capsuleWidth = max(
                0,
                (totalWidth - spacing * CGFloat(steps - 1)) / CGFloat(steps)
            )

            HStack(spacing: spacing) {
                ForEach(0..<steps, id: \.self) { index in
                    Capsule()
                        .fill(index < progress ? Color.blue : Color.gray.opacity(0.3))
                        .frame(width: capsuleWidth, height: 4)
                }
            }
            .frame(width: totalWidth)
            .position(x: geometry.size.width / 2, y: 12)
        }
        .frame(height: 20)
        .padding(.top, 8)
    }
}

#Preview {
    GenderSelectionView()
}
