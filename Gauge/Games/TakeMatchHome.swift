//
//  TakeMatchHome.swift
//  Gauge
//
//  Created by Nikola Cao on 2/10/25.
//

import SwiftUI

struct TakeMatchHome: View {
    var isHost: Bool = false
    
    var body: some View {
            
            VStack() {
                
                Text("Take Match")
                    .frame(width: 200, height: 100)
                    .bold()
                    .foregroundColor(.white)
                    .padding()
                    .background(.gray)
                    .cornerRadius(5)
                HStack() {
                    
                    NavigationLink(destination: GameRoomView(isHost: true)) {
                        
                        Text("Create")
                            .frame(width: 80, height: 15)
                            .bold()
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(5)
                    }
                    
                    NavigationLink(destination: GameRoomView(isHost: false)) {
                        Text("Join")
                            .frame(width: 80, height: 15)
                            .bold()
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(5)
                    }
                }
            }
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
