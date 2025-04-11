//
//  AttributeFormView.swift
//  Gauge
//
//  Created by Sahil Ravani on 4/1/25.
//

import SwiftUI

struct AttributeFormView: View {
    @EnvironmentObject var authVM: AuthenticationVM
    @State private var pronouns = ""
    @State private var age = ""
    @State private var height = ""
    @State private var relationshipStatus = ""
    @State private var workStatus = ""
    @State private var navigateToHome: Bool = false

    var body: some View {
        VStack(spacing: 16) {
                    ProgressBar(progress: 6, steps: 6)
            Spacer().frame(height: 0)

            HStack(spacing: 8) {
                ForEach(0..<4) { _ in
                    Capsule()
                        .fill(Color.blue)
                        .frame(height: 4)
                }
            }
            .padding(.horizontal)
            .hidden()
            
            HStack {
                Button(action: {
                    authVM.onboardingState = .categories
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

            VStack(alignment: .leading, spacing: 8) {
              Text("Lastly, add some attributes to your profile.")
                  .font(.headline)
                  .multilineTextAlignment(.center)

              CustomTextField(placeholder: "Pronouns", text: $pronouns)
              CustomTextField(placeholder: "Age", text: $age)
                  .keyboardType(.numberPad)
              CustomTextField(placeholder: "Height", text: $height)
              CustomTextField(placeholder: "Relationship status", text: $relationshipStatus)
              CustomTextField(placeholder: "Work status", text: $workStatus)
          }
            .padding(.horizontal)

            Spacer()

            Button(action: {
                let attributes: [String: String] = [
                    "pronouns": pronouns,
                    "age": age,
                    "height": height,
                    "relationshipStatus": relationshipStatus,
                    "workStatus": workStatus
                ]
                var updatedAttributes = authVM.tempUserData.attributes
                attributes.forEach { key, value in
                    if !value.isEmpty {
                        updatedAttributes[key] = value
                    }
                }
                authVM.tempUserData.attributes = updatedAttributes
                
                Task {
                        do {
                            try await authVM.updateUserProfile()
                            DispatchQueue.main.async {
                                authVM.onboardingState = .complete
                                navigateToHome = true
                            }
                        } catch {
                            // Handle error
                        }
                    }
                }) {
                    HStack {
                        Spacer()
                        Text("Complete")
                            .foregroundColor(.white)
                            .bold()
                        Spacer()
                    }
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationBarBackButtonHidden(true)
            .onAppear {
                pronouns = authVM.tempUserData.attributes["pronouns"] ?? ""
                age = authVM.tempUserData.attributes["age"] ?? ""
                height = authVM.tempUserData.attributes["height"] ?? ""
                relationshipStatus = authVM.tempUserData.attributes["relationshipStatus"] ?? ""
                workStatus = authVM.tempUserData.attributes["workStatus"] ?? ""
            }
            .navigationDestination(isPresented: $navigateToHome) {
                FeedView()
                    .environmentObject(UserFirebase())
                    .environmentObject(PostFirebase())
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
