//
//  ContentView.swift
//  Gauge
//
//  Created by Datta Kansal on 2/6/25.
//

import SwiftUI

struct ContentView: View {
    @State private var isSigningUp = false
    
    var body: some View {
        VStack {
            if isSigningUp {
                SignUpView()
            } else {
                SignInView()
            }
            Button(action: { isSigningUp.toggle() }) {
                Text(isSigningUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
            }
        }
    }
}

#Preview {
    ContentView()
}
