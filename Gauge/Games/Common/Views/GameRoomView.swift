//
//  GameRoomView.swift
//  Gauge
//
//  Created by Nikola Cao on 2/10/25.
//

import SwiftUI

struct GameRoomView: View {
    @State var showSettings: Bool = false
    @StateObject private var gameSettings = GameSettingsVM()
    @State var isHost: Bool
    @State var roomCode: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        
            
        //vstack for the entire screen
        VStack(spacing: 20) {
            Spacer()
            
            //roomcode
            Text("\(roomCode)")
                .font(.title)
            
            
            
            if isHost {
                Spacer()
                
                //start button to start the game
                NavigationLink(destination: TakeMatchView()) {
                    
                    Text("Start")
                }
                .padding()
                .frame(width: 80, height: 30)
                .background(Color.blue)
                .foregroundColor(.white)
            } else {
                
                Text("Waiting for host...")
            }
            
            Spacer()
            
            //hstack for the icons of the players
            HStack {
                
                
            }
            .frame(maxWidth: .infinity, alignment: .top)
            .frame(height: UIScreen.main.bounds.height / 2) //white bottom half of the screen
            .background(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top) //vstack covers entire screen and aligns to the top
        .navigationTitle(Text("Take Match"))
        .background(Color(.systemGray3))
        .navigationBarTitleDisplayMode(.inline) //places title and cogwheel at the top and center
        .navigationBarBackButtonHidden(true)
        .toolbar { //adds a toolbar for the cogwheel

            if isHost {
                ToolbarItem(placement: .navigationBarTrailing) {
                    
                    //button for openign the settings page
                    Button(action: {
                        showSettings.toggle()
                    }) {
                        Image(systemName: "gearshape")
                            .foregroundColor(.black)
                    }
                }
            }
                
            ToolbarItem(placement: .navigationBarLeading) {
                
                //back button
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.4)) { // Smooth transition
                        dismiss()
                    }
                }) {
                    Image(systemName: "arrow.left")
                        .foregroundColor(.black)
                }
            }
            
        }
        .sheet(isPresented: $showSettings) { // makes the settings page a sheet and not a navigation to another page
            
            GameSettingsView(gameSettings: gameSettings)
                .presentationDetents([.medium]) //stops before full screen
                .presentationDragIndicator(.visible) //shows drag indicator
        }
    }
        
        
}

#Preview {
    NavigationStack {
        GameRoomView(isHost: false, roomCode: "1234")
    }
}

//game settings sheet
struct GameSettingsView: View {
    
    @StateObject var gameSettings = GameSettingsVM()
    
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

