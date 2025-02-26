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
    @State var categories = ["Sports", "Food", "Music", "Pop Culture", "TV Shows", "Movies/Film", "Celebrities"]
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
            GameSettingsView(gameSettings: gameSettings, showSettings: $showSettings, categories: $categories)
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



