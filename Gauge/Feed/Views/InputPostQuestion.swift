//
//  InputPostQuestion.swift
//  Gauge
//
//  Created by Khoa Bui on 4/1/25.
//

import SwiftUI

struct InputPostQuestion: View {
    @State private var questionText: String = ""
    private let maxCharacters = 150
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("New Post")
                .font(.headline)
            
            TextField("What’s your hot take?", text: $questionText)
                .font(.title)
                .foregroundColor(.mediumGray)
                .fontWeight(.bold)
                .multilineTextAlignment(.leading)
                .lineLimit(3)
                .padding(.vertical, 4)
                .onChange(of: questionText) {
                    if questionText.count > maxCharacters {
                        questionText = String(questionText.prefix(maxCharacters))
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
        .padding()
    }
}

#Preview {
    InputPostQuestion()
}

