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
        VStack {
            Text(question).font(.title)
            TextField("Your answer", text: $inputText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Button("Submit", action: onSubmit)
        }
    }
}

#Preview {
    QuestionView(question: "What's the most overrated food?", inputText: .constant(""), onSubmit: { })
}
