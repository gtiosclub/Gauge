//
//  InputPostQuestion.swift
//  Gauge
//
//  Created by Khoa Bui on 4/1/25.
//

import SwiftUI

struct InputPostQuestion: View {
    @Binding var questionText: String
    @Binding var stepCompleted: Bool
    private let maxCharacters = 150
    
    var body: some View {
        VStack(alignment: .leading) {
            TextField("What’s your hot take?", text: $questionText)
                .font(.title)
                .foregroundColor(.black)
                .fontWeight(.bold)
                .multilineTextAlignment(.leading)
                .lineLimit(3)
                .onChange(of: questionText) {
                    if questionText.count > maxCharacters {
                        questionText = String(questionText.prefix(maxCharacters))
                    }
                    
                    withAnimation(.easeInOut(duration: 0.2)) {
                        stepCompleted = !questionText.isEmpty
                    }
                }
                .onAppear {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        stepCompleted = !questionText.isEmpty
                    }
                }

            Spacer(minLength: 50.0)

            HStack {
                Spacer()
                Text("\(questionText.count)/\(maxCharacters) characters")
                    .foregroundColor(.gray)
                    .font(.footnote)
                Spacer()

            }
        }
        .padding(.horizontal)
    }
}

#Preview {
//    InputPostQuestion()
}

