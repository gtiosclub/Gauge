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
        VStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemFill))
                    .frame(height: 250)
                Text(question).font(.title)
                    .padding()
            }
            InfoField(title: "A:", text: $inputText)
            Button(action: {
                onSubmit()
            }) {
                Text("Submit")
                    .font(.headline)
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
            .padding(.top, 20)

        }.padding()
    }
}

#Preview {
    QuestionView(question: "Q: Some question about this person's preferences", inputText: .constant(""), onSubmit: { })
}

struct InfoField: View {
    let title:String
    @Binding var text:String
    @FocusState var isTyping:Bool
    var body: some View {
        ZStack(alignment: .leading) {
            TextField("", text: $text).padding(.leading)
                .frame(height: 250).focused($isTyping)
                .background(isTyping ? .black : Color(.gray),in:RoundedRectangle(cornerRadius: 14).stroke(lineWidth: 2))
                .font(.title)
          
            Text(title).padding(.horizontal, 5)
                .background(.white.opacity(isTyping || !text.isEmpty ? 1 : 0))
                .foregroundStyle(isTyping ? .black : .black)
                .padding(.leading).offset(y: isTyping || !text.isEmpty ? -27 : 0)
                .onTapGesture {
                    isTyping.toggle()
                }
                .font(.title)

        }
        .animation(.linear(duration: 0.2), value: isTyping)
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
