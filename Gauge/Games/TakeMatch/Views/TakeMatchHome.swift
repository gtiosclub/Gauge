//
//  TakeMatchHome.swift
//  Gauge
//
//  Created by Nikola Cao on 2/10/25.
//

import SwiftUI

struct TakeMatchHome: View {
    var isHost: Bool = false
    @State var roomCode: String = ""
    @State var showJoinRoom: Bool = false
    
    var body: some View {
            
            VStack {
                
                Text("Take Match")
                    .frame(width: 200, height: 100)
                    .bold()
                    .foregroundColor(.white)
                    .padding()
                    .background(.gray)
                    .cornerRadius(5)
                HStack {
                    
                    NavigationLink(destination: TakeMatchRoomView(isHost: true, roomCode: roomCode)) {
                        
                        Text("Create")
                            .frame(width: 80, height: 15)
                            .bold()
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(5)
                    }
                    
                    Button(action: { withAnimation(.easeInOut(duration: 0.3)) {
                        
                            showJoinRoom.toggle()
                        }
                    }) {
                        Text("Join")
                            .frame(width: 80, height: 15)
                            .bold()
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(5)
                    }
                    
                }
                
                if showJoinRoom {
                    
                    HStack {
                        
                        TextField("Room Code", text: $roomCode)
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color.gray, lineWidth: 2) // Thin outline
                            )
                            .frame(width: 170)
                        
                        if roomCode.isEmpty {
                            
                                
                            Image(systemName: "arrow.right")
                                .foregroundColor(.black)
                                .padding()
                                .background(.gray)
                                .cornerRadius(5)
                                .opacity(0.1)
                            
                        } else {
                            NavigationLink(destination: TakeMatchRoomView(isHost: false, roomCode: roomCode)) {
                                
                                Image(systemName: "arrow.right")
                                    .foregroundColor(.black)
                            }
                            .padding()
                            .background(.gray)
                            .cornerRadius(5)
                        }
                    }
                    .transition(.opacity)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .frame(width: 200)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    
                    NavigationLink(destination: GamesHome()) {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.black)
                    }
                }
            }
    }
}

#Preview {
    NavigationStack {
        TakeMatchHome()
    }
}
