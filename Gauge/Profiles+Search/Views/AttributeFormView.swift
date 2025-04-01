//
//  AttributeFormView.swift
//  Gauge
//
//  Created by Sahil Ravani on 4/1/25.
//

import SwiftUI

struct AttributeFormView: View {
    @State private var pronouns = ""
    @State private var height = ""
    @State private var relationshipStatus = ""
    @State private var workStatus = ""
    @State private var religion = ""
    @State private var ethnicity = ""
    @State private var politicalBeliefs = ""

    var body: some View {
        VStack(spacing: 16) {
            Spacer().frame(height: 0)

            HStack(spacing: 8) {
                ForEach(0..<4) { _ in
                    Capsule()
                        .fill(Color.blue)
                        .frame(height: 4)
                }
            }
            .padding(.horizontal)

            HStack {
                Button(action: {
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.gray)
                }

                Spacer()

                Text("About You")
                    .font(.headline)
                    .bold()

                Spacer()

                Image(systemName: "chevron.left")
                    .opacity(0)
            }
            .padding(.horizontal)

            Text("Lastly, add some attributes to your profile.")
                .font(.headline)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)

            // Fields
            CustomTextField(placeholder: "Pronouns", text: $pronouns)
            CustomTextField(placeholder: "Height", text: $height)
            CustomTextField(placeholder: "Relationship status", text: $relationshipStatus)
            CustomTextField(placeholder: "Work status", text: $workStatus)
            CustomTextField(placeholder: "Religion", text: $religion)
            CustomTextField(placeholder: "Ethnicity", text: $ethnicity)
            CustomTextField(placeholder: "Political Beliefs", text: $politicalBeliefs)

            Spacer()

            Button(action: {
           
            }) {
                Text("Next")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
    }
}


struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String

    var body: some View {
        TextField(placeholder, text: $text)
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            .padding(.horizontal)
    }
}

#Preview {
    AttributeFormView()
}
