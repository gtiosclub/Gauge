//
//  GameRoomView.swift
//  Gauge
//
//  Created by Nikola Cao on 2/10/25.
//

import SwiftUI

struct TakeMatchRoomView: View {
    @StateObject private var mcManager = MCManager.shared
    @State var showSettings: Bool = false
    @StateObject private var gameSettings = TakeMatchSettingsVM()
    @State var isHost: Bool
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            // Display the room code
            Text("Room Code: \(mcManager.roomCode)")
                .font(.title)
                .bold()

            if isHost {
                Spacer()
                
                Button("Start") {
                    mcManager.sendMessage("StartGame")
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
                
                ForEach(mcManager.connectedPeers, id: \.self) { peer in
                    VStack {
                        Image(systemName: "person.circle.fill") // Player Icon
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.blue)

                        Text(peer.displayName) // Player Name
                            .font(.caption)
                            .lineLimit(1)
                            .frame(width: 80)
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
        .onAppear {
            mcManager.refreshConnectedPeers()
            if isHost == false {
                mcManager.sendMessage("RequestRoomCode") // Ask host for room code
                
            }
        }
        .onReceive(mcManager.$connectedPeers) { _ in
            print("UI updated with connected peers: \(mcManager.connectedPeers.map { $0.displayName })")
        }
        .onDisappear {
            if isHost {
                mcManager.stopHosting()
            } else {
                mcManager.stopBrowsing()
            }
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
        TakeMatchRoomView(isHost: true)
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

