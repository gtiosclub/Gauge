//
//  TagEditView.swift
//  Gauge
//
//  Created by Ajay Desai on 4/3/25.
//

import SwiftUI

struct TagEditView: View {
    let title: String
    @State private var tagValue: String
    let placeholder: String
    @Environment(\.dismiss) private var dismiss
    @State private var showVisibilityToggle: Bool = true
    @State private var isVisible: Bool = true
    
    init(title: String, value: String, placeholder: String) {
        self.title = title
        self._tagValue = State(initialValue: value)
        self.placeholder = placeholder
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Image(systemName: "face.smiling")
                    .font(.system(size: 24))
                    .foregroundColor(.gray)
                
                TextField(placeholder, text: $tagValue)
                    .padding(10)
                    .background(Color(UIColor.systemGray5))
                    .cornerRadius(10)
                
                if !tagValue.isEmpty {
                    Button(action: {
                        tagValue = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.horizontal)
            
            if showVisibilityToggle {
                HStack {
                    Spacer()
                    Text("profile visibility")
                        .foregroundColor(.gray)
                        .font(.system(size: 14))
                    
                    Toggle("", isOn: $isVisible)
                        .labelsHidden()
                }
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .padding(.top, 20)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    // Save changes and dismiss
                    dismiss()
                }
                .foregroundColor(.blue)
            }
        }
    }
}

struct TagEditView_Previews: PreviewProvider {
    static var previews: some View {
        TagEditView(title: "Gender", value: "", placeholder: "username's gender")
    }
}
