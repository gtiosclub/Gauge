//
//  QuestionView.swift
//  Gauge
//
//  Created by Seohyun Park on 2/11/25.
//

import SwiftUI

struct QuestionView: View {
    var question: String
    @Binding var inputText: String
    var onSubmit: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemFill))
                    .frame(height: 250)
                Text(question).font(.title)
                    .padding()
            }
            InfoField(text: $inputText)
            Button(action: {
                onSubmit()
            }) {
                Text("Submit")
                    .font(.title)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.gray)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.2), radius: 4, x: 2, y: 2)
                    .scaleEffect(1.0)
            }
            .buttonStyle(PressEffectButtonStyle())
            .padding(.horizontal, 40)
        }.padding()
    }
}

struct InfoField: View {
    @Binding var text: String
    @FocusState private var isTyping: Bool
    let title: String = "A:"
    
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 14)
                .stroke(lineWidth: 2)
                .foregroundColor(isTyping ? .black : .gray)
                .frame(height: 250)
            
            TextEditor(text: $text)
                .padding(.horizontal, 10)
                .focused($isTyping)
                .frame(height: max(250, min(50, dynamicHeight())))
                .font(.title)
                .opacity(text.isEmpty ? 0.8 : 1)

            if text.isEmpty {
                Text(title)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 14)
                    .font(.title)
                    .onTapGesture {
                        isTyping = true
                    }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isTyping)
        .padding()
    }

    private func dynamicHeight() -> CGFloat {
        let lineCount = CGFloat(text.split(separator: "\n").count + 1)
        return min(250, max(50, lineCount * 30))
    }
}

struct PressEffectButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
