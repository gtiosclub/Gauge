//
//  GameRoomView.swift
//  Gauge
//
//  Created by Nikola Cao on 2/10/25.
//

import SwiftUI

struct TakeMatchRoomView: View {
    @ObservedObject var mcManager: MCManager
    @State var showSettings: Bool = false
    @StateObject private var gameSettings = TakeMatchSettingsVM()
    @State var isHost: Bool

    @State var categories = ["Sports", "Food", "Music", "Pop Culture", "TV Shows", "Movies/Film", "Celebrities"]

    var roomCode: String
    var onExit: () -> Void
  
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            // Display the room code
            Text(isHost ? "Hosting Room: \(roomCode)" : "Joined Room: \(roomCode)")
                .font(.title)
                .bold()

            if isHost {
                
                Button("Start") {
                    
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
                    
                    Text("You: \(mcManager.myPeerID.displayName)")
                        .foregroundColor(.blue)
                    
                    ForEach(mcManager.connectedPeers, id:\.self) { peer in
                        Text(peer.displayName)
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
            GameSettingsView(gameSettings: gameSettings, showSettings: $showSettings, categories: $categories)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .onDisappear {
            if !isHost {
                mcManager.session.disconnect()
            }
            mcManager.isAvailableToPlay = false
            mcManager.stopBrowsing()
        }
    }
}

#Preview {
    NavigationStack {
        TakeMatchRoomView(mcManager: MCManager(yourName: "test"), isHost: true, roomCode: "ABCD", onExit: {})
    }
}

//game settings sheet
struct GameSettingsView: View {
    
    @StateObject var gameSettings = TakeMatchSettingsVM()
    @Binding var showSettings: Bool
    @Binding var categories: [String]
    
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
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ForEach(categories, id: \.self) { category in
                            Button(action: {
                                // Handle category selection
                            }) {
                                Text(category)
                                    .font(.body)
                                    .foregroundColor(.black)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.white)
                                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.black, lineWidth: 1))
                            }
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



