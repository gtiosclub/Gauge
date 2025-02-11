//
//  FirebaseTesting.swift
//  Gauge
//
//  Created by Austin Huguenard on 2/10/25.
//

import SwiftUI

struct FirebaseTesting: View {
    @EnvironmentObject var postVM: PostFirebase
    @EnvironmentObject var userVM: UserFirebase

    var body: some View {
        VStack(spacing: 20) {
            Section("Write Data") {
                // Krish Tests
                Button("Add Binary Post") {
                    postVM.createBinaryPost(
                        userId: "tfeGCRCgt8UbJhCmKgNmuIFVzD73",
                        category: .food,
                        question: "Is pizza the goat food?",
                        responseOption1: "yes",
                        responseOption2: "no"
                    )
                }
                
                Button("Add Slider Post") {
                    postVM.createSliderPost(
                        userId: "xEZWt93AaJZPwfHAjlqMjmVP0Lz1",
                        category: .tech,
                        question: "rate Swift 1-10",
                        lowerBoundValue: 1,
                        upperBoundValue: 10,
                        lowerBoundLabel: "Terrible 🤮",
                        upperBoundLabel: "Goated 🐐"
                    )
                }
                
                Button("Add Ranked Post") {
                    postVM.createRankPost(
                        userId: "2lCFmL9FRjhY1v1NMogD5H6YuMV2",
                        category: .entertainment,
                        question: "Best Half-Time Performance?",
                        responseOptions: ["Kendrick Lamar", "Rihanna", "The Weeknd", "Shakira + J Lo"]
                    )
                }
            }
            
            Section("Get Live Data (Great for feed & games!)") {
                Button("Watch for Posts") {
                    postVM.getLiveFeedPosts(user: userVM.user)
                }
            }
            
            Section("Read Data") {
                
            }
            
            Section("Update Data") {
                
            }
            
            Section("View Data") {
                
            }
        }
        .onAppear() {
            print("\(Keys.openAIKey)")
        }
    }
}

#Preview {
    FirebaseTesting()
}
