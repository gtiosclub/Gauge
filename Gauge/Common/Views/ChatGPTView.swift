//
//  ChatGPTView.swift
//  Gauge
//
//  Created by Dahyun on 2/19/25.
//

import Foundation
import SwiftUI

struct ChatGPTView: View {
    @StateObject private var viewModel = ChatGPTVM()
    @State private var userInput: String = ""
    
    var body: some View {
        VStack {
            // Chat history
            ScrollView {
                ForEach(viewModel.messages) { message in
                    MessageView(message: message)
                }
            }
            
            // User input and send button
            HStack {
                TextField("Enter your message", text: $userInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disabled(viewModel.isQuerying)
                
                Button(action: {
                    Task {
                        await viewModel.sendNewMessage(content: userInput)
                        userInput = ""
                    }
                }) {
                    if viewModel.isQuerying {
                        ProgressView()
                    } else {
                        Text("Send")
                    }
                }
                .disabled(viewModel.isQuerying || userInput.isEmpty)
            }
            .padding()
            
            // Error message
            if let latestAIResponse = viewModel.latestAIResponse {
                Text(latestAIResponse)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .navigationTitle("Atlas AI Assistant")
    }
}

struct MessageView: View {
    let message: Message
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
                Text(message.content)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            } else {
                Text(message.content)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .foregroundColor(.black)
                    .cornerRadius(10)
                Spacer()
            }
        }
        .padding(.horizontal)
    }
}
#Preview {
    ChatGPTView()
}
