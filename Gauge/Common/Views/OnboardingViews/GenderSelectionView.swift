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
            ProgressBar(progress: 1, steps: 6, spacing: 8, barFraction: 7 / 8.0)
            
            ZStack {
                Text("About You")
                    .font(.system(size: 17, weight: .semibold))
            }
            .padding(.top, 12)
            .padding(.horizontal, 18)
            
            Spacer().frame(height: 100)
            
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
                    Text("Next")
                        .foregroundColor(.white)
                        .bold()
                    Image(systemName: "arrow.right")
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding()
                .background(Color.blue)
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

#Preview {
    GenderSelectionView()
}
