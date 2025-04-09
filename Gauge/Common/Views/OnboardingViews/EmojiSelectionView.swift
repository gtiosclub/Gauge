//
//  EmojiSelectionView.swift
//  Gauge
//
//  Created by Anthony Le on 4/4/25.
//

import SwiftUI
import UIKit

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
                    
                    EmojiTextFieldRepresentable(text: $emoji)
                        .frame(width: 168, height: 168)
                    
                    Spacer()
                }
            }
            .padding(.horizontal, 24)

            Spacer()

            Button(action: {
                navigateToBioCreation = true
            }) {
                skipOrNextActionButton(toSkip: emoji.isEmpty)
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

extension String {
    var containsOnlyEmoji: Bool {
        return self.count == 1 && self.unicodeScalars.allSatisfy { $0.properties.isEmoji || $0.properties.isEmojiPresentation }
    }
}

struct EmojiTextFieldRepresentable: UIViewRepresentable {
    @Binding var text: String

    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: EmojiTextFieldRepresentable

        init(_ parent: EmojiTextFieldRepresentable) {
            self.parent = parent
        }

        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            let currentText = textField.text ?? ""
            let newText = (currentText as NSString).replacingCharacters(in: range, with: string)

            if newText.count > 1 {
                return false
            }

            if !newText.isEmpty && !newText.containsOnlyEmoji {
                return false
            }

            parent.text = newText
            return true
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> EmojiTextField {
        let textField = EmojiTextField()
        textField.delegate = context.coordinator
        textField.textAlignment = .center
        textField.font = UIFont.systemFont(ofSize: 120)
        textField.backgroundColor = UIColor.gray.withAlphaComponent(0.2)
        textField.layer.cornerRadius = 84
        textField.clipsToBounds = true
        return textField
    }

    func updateUIView(_ uiView: EmojiTextField, context: Context) {
        uiView.text = text
    }
}

class EmojiTextField: UITextField {
    override var textInputMode: UITextInputMode? {
        .activeInputModes.first(where: { $0.primaryLanguage == "emoji" })
    }
}


#Preview {
    EmojiSelectionView()
}
