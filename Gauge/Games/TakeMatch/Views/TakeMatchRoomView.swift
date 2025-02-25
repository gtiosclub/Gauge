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
    var roomCode: String
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
                        dismiss()
                    }
                }) {
                    Image(systemName: "arrow.left")
                        .foregroundColor(.black)
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            GameSettingsView(gameSettings: gameSettings)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }
}

#Preview {
    NavigationStack {
        TakeMatchRoomView(mcManager: MCManager(yourName: "test"), isHost: true, roomCode: "ABCD")
    }
}

//game settings sheet
struct GameSettingsView: View {
    
    @StateObject var gameSettings = TakeMatchSettingsVM()
    
    var body: some View {
        
        VStack() {
            
            Text("Customize Game")
                .font(.headline)
                .padding()
            
            Form {
                
                Section {
                    
                    Picker("Rounds", selection: $gameSettings.numRounds) {
                        
                        ForEach(1...5, id: \.self) { round in
                            Text("\(round)").tag(round)
                        }
                    }
                    
                }
                .listRowBackground(Color(.systemGray4))
            }
            .scrollContentBackground(.hidden)
            .background(.white)
            
        }
        .background(.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

#Preview {
    GameSettingsView()
}

