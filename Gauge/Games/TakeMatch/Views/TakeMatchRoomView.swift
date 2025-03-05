//
//  GameRoomView.swift
//  Gauge
//
//  Created by Nikola Cao on 2/10/25.
//

import SwiftUI

struct TakeMatchRoomView: View {
    @ObservedObject var mcManager: MCManager

    @ObservedObject var gameSettings = TakeMatchSettingsVM.shared
    @StateObject private var chatGPTVM = ChatGPTVM()
    
    @State var showSettings: Bool = false
    @State var isHost: Bool
    @State private var navigateToTakeMatch = false
    
    var roomCode: String
    var onExit: () -> Void
  
    @Environment(\.dismiss) private var dismiss
    
    @State var answerText: String = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()
                Text(isHost ? "Hosting Room: \(roomCode)" : "Joined Room: \(roomCode)")
                    .font(.title)
                    .bold()
                
                if isHost {
                    
                    Button("Start") {
                         if let topic = gameSettings.selectedCategories.randomElement() {
                             gameSettings.selectedTopic = topic
                             Task {
                                 await chatGPTVM.generateQuestion(from: [topic])
                                 if let question = chatGPTVM.storedQuestions.last {
                                     gameSettings.question = question
                                     mcManager.broadcastStartGame()
                                     mcManager.gameStarted = true
                                     mcManager.broadcastQuestion(question)
                                 }
                             }
                         }
                        gameSettings.clearCategories()
                    }
                    .padding()
                    .frame(width: 80, height: 30)
                    .background(Color.blue)
                    .foregroundColor(.white)
                } else {
                    Text("Waiting for host...")
                }
                Spacer()
                HStack {
                    VStack {
                        
                        Text("Participants:")
                            .font(.headline)
                        
                        Text("You: \(mcManager.username)")
                            .foregroundColor(.blue)
                        
                        ForEach(mcManager.connectedPeers, id:\.self) { peer in
                            Text(mcManager.discoveredPeers[peer]?.username ?? peer.displayName)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .top)
                .frame(height: UIScreen.main.bounds.height / 2)
                .background(.white)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .navigationTitle(Text("Take Match"))
            .background(Color(.systemGray3))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .onDisappear {
                mcManager.isAvailableToPlay = false
                mcManager.stopBrowsing()
            }
            .toolbar {
                if isHost {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showSettings.toggle()
                        }) {
                            Image(systemName: "gearshape")
                                .foregroundColor(.black)
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            mcManager.isAvailableToPlay = false
                            onExit()
                            dismiss()
                        }
                    }) {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.black)
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                GameSettingsView(gameSettings: gameSettings, showSettings: $showSettings)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }

//            .navigationDestination(isPresented: $mcManager.gameStarted) {
//                QuestionView(
//                    mcManager: mcManager,
//                    question: "What is your favorite color?",
//                    inputText: $answerText,
//                    onSubmit: {
//                        mcManager.submitAnswer(answerText)
//                        answerText = ""
//                    }
//                )
//            }
        }
        .navigationDestination(isPresented: $mcManager.gameStarted) {
            TakeMatchView(mcManager: mcManager, gameSettings: gameSettings)
        }

    }
    
}

#Preview {
    NavigationStack {
        TakeMatchRoomView(mcManager: MCManager(yourName: "test"), isHost: true, roomCode: "ABCD", onExit: {})
    }
}
struct CategoryView: View{
    @Binding var selectedCategories: [String]
    var categoryName: String
    var isSelected: Bool {
        selectedCategories.contains(categoryName)
    }
    var body: some View {
        Text(categoryName)
            .font(.body)
            .foregroundColor(.black)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(isSelected ? Color.blue.opacity(0.2) : Color.white)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(Color.black, lineWidth: 1)
            )
            .onTapGesture {
                if selectedCategories.contains(categoryName) {
                    selectedCategories.removeAll(where: {$0 == categoryName})
                } else {
                    selectedCategories.append(categoryName)
                }

            }
    }
}

//game settings sheet
struct GameSettingsView: View {
    
    @ObservedObject var gameSettings = TakeMatchSettingsVM.shared
    @Binding var showSettings: Bool

    let categories: [String] = ["Sports", "Food", "Music", "Pop Culture", "TV Shows", "Movies/Film", "Celebrities"]

    
    var body: some View {
        
        VStack() {
            Text("Game Settings")
                .font(.title)
                .bold()
                .padding()
            
            Form {
                HStack() {
                    Text("# of Rounds").font(.headline)
                    Section {
                        
                        Picker("", selection: $gameSettings.numRounds) {
                            
                            ForEach(1...5, id: \.self) { round in
                                Text("\(round)").tag(round)
                            }
                        }
                        
                    }
                    .listRowBackground(Color(.systemGray4))
                }
                HStack() {
                    Text("Round Length").font(.headline)
                    Section {
                        
                        Picker("", selection: $gameSettings.roundLen) {
                            
                            ForEach([15,30,45,60], id: \.self) { length in
                                Text("\(length)s").tag(length)
                            }
                        }
                        
                    }
                    .listRowBackground(Color(.systemGray4))
                }
                VStack(alignment: .leading, spacing: 10) {
                    Text("Categories")
                        .font(.headline)
                    //can select multiple categories, depending on number of rounds & randomness not all categories may be used
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ForEach(categories, id: \.self) { category in
                            CategoryView(selectedCategories: $gameSettings.selectedCategories, categoryName: category)
                        }
                    }
                }
                .padding(.horizontal)
                
                Text("Looking good?")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Button(action: {
                    // Handle done action
                    showSettings = false
                }) {
                    Text("DONE")
                        .font(.headline)
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray3))
                        .cornerRadius(8)
                        .foregroundColor(.black)
                }
               
            }
            .scrollContentBackground(.hidden)
            .background(.white)
            
        }
        .background(.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
    

}



