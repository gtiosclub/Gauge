//
//  BioCreationView.swift
//  Gauge
//
//  Created by Anthony Le on 4/4/25.
//

import SwiftUI

struct BioCreationView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var bio: String = ""
    @State private var showSuggestions: Bool = true
    @State private var isProgammaticChange: Bool = false
    @State private var toSkip: Bool = true

    var body: some View {
        VStack(spacing: 0) {
            AboutYouProgressBar(progress: 4)
            
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
                
            }) {
                skipOrNextActionButton(toSkip: bio.isEmpty)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 8)

            Spacer().frame(height: 0)
        }
        .navigationBarBackButtonHidden(true)
        
//        add navigation to next step
//        .navigationDestination(isPresented: $navigateTo) {
//        }
    }
}
#Preview {
    BioCreationView()
}
