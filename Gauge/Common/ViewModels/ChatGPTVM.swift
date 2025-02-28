//
//  ChatGPTVM.swift
//  Gauge
//
//  Created by Dahyun on 2/18/25.
//

import Foundation
import SwiftUI
import ChatGPTSwift

@MainActor
class ChatGPTVM: ObservableObject {
    @Published var isInteractingWithChat = false
    @Published var messages: [Message] = [Message(content: "Pick a topic to generate a take!", isUser: false)]
    @Published var isQuerying = false
    @Published var latestAIResponse: String?
    @Published var storedQuestions: [String] = []
    
    var gptKey = ChatGPTAPI(apiKey: "<PUT API KEY HERE>")
    
    let initialConditionSentence:String = """
    Ask me a topic to generate a hot new take.
    """
    
    init() {
       fetchAPIKeys()
    }

    private func fetchAPIKeys() {
        Task {
            do {
                let doc = try await Firebase.db.collection("KEYS").document("OpenAI").getDocument()
                
                
                guard let data = doc.data(), let key = data["key"] as? String else {
                    throw NSError(domain: "FirebaseError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Key not found"])
                }
                
                self.gptKey = ChatGPTAPI(apiKey: key)
            } catch {
                print("Failed to fetch API keys: \(error)")
            }
        }
    }
    
    func sendNewMessage(content: String) async {
        guard !content.isEmpty else {
            latestAIResponse = "Please enter a message."
            return
        }
            
            
        let userMessage = Message(content: content, isUser: true)
            
        // Update UI state on the main thread
        self.messages.append(userMessage)
        self.isQuerying = true
            
        do {
            let response = try await gptKey.sendMessage(text: content)
            
            // Update UI state on the main thread
            self.messages.append(Message(content: response, isUser: false))
            self.isQuerying = false
        } catch {
                // Update UI state on the main thread
            self.latestAIResponse = "Error: \(error.localizedDescription)"
            self.isQuerying = false
            }
        }
    
    func generateQuestion(from categories: [String]) async {
        guard !categories.isEmpty else {
            latestAIResponse = "Please select a topic."
            return
        }
            
        for category in categories {
            let prompt = "Generate a divisive opinion-based question about \(category)"
            self.isQuerying = true
            do {
                let response = try await gptKey.sendMessage(text: prompt)
                
                // Update UI state on the main thread
                self.storedQuestions.append(response)
                self.isQuerying = false
            } catch {
                    // Update UI state on the main thread
                self.latestAIResponse = "Error generating question for \(category): \(error.localizedDescription)"
                self.isQuerying = false
            }
        }
    }
            
        
    
    func startNewChat() {
       messages = [
        Message(content: "Please ", isUser: false)
       ]
       latestAIResponse = nil
    }
    
    
}


struct Message: Identifiable {
    let id = UUID()
    let content: String
    let isUser: Bool
}
