//
//  GenderSelectionView.swift
//  Gauge
//
//  Created by Anthony Le on 4/3/25.
//
import SwiftUI

struct GenderSelectionView: View {
    @EnvironmentObject var authVM: AuthenticationVM
    @State private var genderSelection: String = ""
    let genderOptions = ["Male", "Female", "Other"]

    var body: some View {
        VStack(spacing: 0) {
            ProgressBar(progress: 1, steps: 6)  // Adjust steps count as needed for “About You” flow
            // Header
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
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                    )
                }
            }
            .padding(.horizontal, 24)

            Spacer()
            
            Button(action: {
                authVM.tempUserData.attributes["gender"] = genderSelection
                authVM.onboardingState = .location
            }) {
                skipOrNextActionButton(toSkip: genderSelection.isEmpty)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 8)
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            genderSelection = authVM.tempUserData.attributes["gender"] ?? ""
        }
    }
}

struct skipOrNextActionButton: View {
    var toSkip: Bool
    
    var body: some View {
        HStack {
            Spacer()
            Text(toSkip ? "Skip" : "Next")
                .foregroundColor(toSkip ? .blue : .white)
                .bold()
            
            if (!toSkip) {
                Image(systemName: "arrow.right")
                    .foregroundColor(.white)
            }
            
            Spacer()
        }
        .padding()
        .background(toSkip ? Color(red: 0.843, green: 0.918, blue: 0.996) : Color.blue)
        .cornerRadius(25)
    }
}
