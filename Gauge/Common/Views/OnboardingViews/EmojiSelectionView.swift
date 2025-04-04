//
//  EmojiSelectionView.swift
//  Gauge
//
//  Created by Anthony Le on 4/4/25.
//

import SwiftUI

extension String {
    var containsOnlyEmoji: Bool {
        return self.count == 1 && self.unicodeScalars.allSatisfy { $0.properties.isEmoji || $0.properties.isEmojiPresentation }
    }
}

struct EmojiSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var navigateToBioCreation: Bool = false
    @State private var emoji: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            AboutYouProgressBar(progress: 3)
            
            ZStack {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.blue)
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
                Text("Pick an emoji to display on your profile.")
                    .font(.title)
                    .bold()
                    .padding(.bottom, 20)
                
                HStack {
                    Spacer()
                    
                    TextField("", text: $emoji)
                        .onChange(of: emoji, initial: false) { _, newValue in
                            if newValue.count > 1 {
                                emoji = String(newValue.prefix(1))
                            }
                            
                            if (!emoji.containsOnlyEmoji) {
                                emoji = ""
                            }
                        }
                        .frame(width: 168, height: 168)
                        .background(Color.gray.opacity(0.2))
                        .multilineTextAlignment(.center)
                        .clipShape(Circle())
                        .keyboardType(.default)
                        .font(.system(size: 120))
                    
                    Spacer()
                }
            }
            .padding(.horizontal, 24)

            Spacer()

            Button(action: {
                navigateToBioCreation = true
            }) {
                HStack {
                    Spacer()
                    Text(emoji.isEmpty ? "Skip" : "Next")
                        .foregroundColor(.white)
                        .bold()
                    Image(systemName: "arrow.right")
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding()
                .background(Color.blue)
                .opacity(emoji.isEmpty ? 0.4 : 1.0)
                .cornerRadius(25)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 8)

            Spacer().frame(height: 0)
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $navigateToBioCreation) {
            BioCreationView()
        }
    }
}

#Preview {
    EmojiSelectionView()
}
