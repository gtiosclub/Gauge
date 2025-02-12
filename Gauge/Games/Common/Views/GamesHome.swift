//
//  GamesHome.swift
//  Gauge
//
//  Created by Akshat Shenoi on 2/6/25.
//

import SwiftUI

struct GamesHome: View {
    // Will include a tab list view of all the games in the app
    var body: some View {
        
        NavigationView {
            
            VStack(spacing: 20) {
                
                NavigationLink(destination: TakeMatchHome()) {
                    Text("Take Match")
                        .padding()
                        .foregroundColor(.white)
                        .background(.blue)
                        .cornerRadius(10)
                }
                .navigationTitle(Text("Games"))
            }
            
        }
    }
}

#Preview {
    GamesHome()
}
