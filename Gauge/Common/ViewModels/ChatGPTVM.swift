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

        self.isQuerying = true
        self.storedQuestions.removeAll() // Clear previous questions

        // Ensure we have exactly 4 topics (repeat or shuffle if necessary)
        var selectedCategories = categories
        while selectedCategories.count < 4 {
            selectedCategories.append(categories.randomElement() ?? "random topic") // Fill up to 4
        }
        selectedCategories.shuffle() // Shuffle to add randomness

        do {
            // Generate 4 questions concurrently
            let q1 = try await gptKey.sendMessage(text: generatePrompt(for: selectedCategories[0]))
            let q2 = try await gptKey.sendMessage(text: generatePrompt(for: selectedCategories[1]))
            let q3 = try await gptKey.sendMessage(text: generatePrompt(for: selectedCategories[2]))
            let q4 = try await gptKey.sendMessage(text: generatePrompt(for: selectedCategories[3]))
//            let q1 = "Does pineapple belong on pizza?"
//            let q2 = "What is the most interesting fact about sloths?"
//            let q3 = "Can you name 5 things that are both edible and poisonous?"
//            let q4 = "What is the most spontaneous thing you have ever done?"

            let responses = [q1, q2, q3, q4] // Wait for all responses


            self.storedQuestions = responses
            self.isQuerying = false

        } catch {
            DispatchQueue.main.async {
                self.latestAIResponse = "Error generating questions: \(error.localizedDescription)"
                self.isQuerying = false
            }
        }
    }

    // Helper function to generate a question prompt
    private func generatePrompt(for category: String) -> String {
        return "Generate a short, fun, and light-hearted open-ended question about \(category) that sparks discussion among friends. Avoid yes/no or either-or questions. The question should prompt answers that are short and quick, rather than lengthy explanations. Don't ask why or how the questions shouldn't be more than 12 words each."
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
