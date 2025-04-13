//
//  BioCreationView.swift
//  Gauge
//
//  Created by Anthony Le on 4/4/25.
//

import SwiftUI

struct BioCreationView: View {
    @EnvironmentObject var authVM: AuthenticationVM
    @State private var bio: String = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            ProgressBar(progress: 4, steps: 6)
            
            ZStack {
                HStack {
                    Button(action: {
                        authVM.onboardingState = .profileEmoji
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                
                Text("About You")
                    .font(.system(size: 17, weight: .semibold))
            }
            .padding(.top, 12)
            .padding(.horizontal, 18)
            
            Spacer().frame(height: 30)
            
            VStack(alignment: .leading, spacing: 8) {
                            Text("Create a bio to display on your profile.")
                                .font(.title)
                                .bold()
                                .padding(.bottom, 20)
                            
                            TextField("This is optional.", text: $bio, axis: .vertical)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                                .lineLimit(5)
                        }
                        .padding(.horizontal, 24)
                        
                        Spacer()
                        
                        Button(action: {
                            authVM.tempUserData.bio = bio
                            authVM.onboardingState = .categories
                        }) {
                            skipOrNextActionButton(toSkip: bio.isEmpty)
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 8)
                    }
                    .navigationBarBackButtonHidden(true)
                    .onAppear {
                        bio = authVM.tempUserData.bio
                    }
                }
}
#Preview {
    BioCreationView()
}
