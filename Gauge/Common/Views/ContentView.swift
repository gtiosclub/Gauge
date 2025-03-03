//
//  ContentView.swift
//  Gauge
//
//  Created by Datta Kansal on 2/6/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var authVM = AuthenticationVM()
    @EnvironmentObject var userVM: UserFirebase
    @State private var isSigningUp = false
    @State private var selectedTab: Int = 0
    @State private var showSplashScreen: Bool = true
    
    var body: some View {
        if showSplashScreen {
            ZStack {
                Image(systemName: "gauge.open.with.lines.needle.84percent.exclamation")
                    .resizable()
                    .scaledToFit()
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            }
            .background(.red)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    showSplashScreen = false
                }
            }
        } else {
            VStack {
                if authVM.currentUser != nil {
                    TabView(selection: $selectedTab) {
                        HomeView()
                            .tabItem {
                                Image(systemName: "house")
                                Text("Home")
                            }
                            .tag(0)
                        
                        Text("Search")
                            .tabItem {
                                Image(systemName: "magnifyingglass")
                                Text("Search")
                            }
                            .tag(1)
                        
                        Text("Games")
                            .tabItem {
                                Image(systemName: "person.line.dotted.person.fill")
                                Text("Games")
                            }
                            .tag(2)
                        
                        Text("Profile")
                            .tabItem {
                                Image(systemName: "person.circle")
                                Text("Profile")
                            }
                            .tag(3)
                    }
                    .background(.white)
                } else {
                    if isSigningUp {
                        SignUpView()
                            .environmentObject(authVM)
                    } else {
                        SignInView()
                            .environmentObject(authVM)
                    }
                    
                    Button(action: { isSigningUp.toggle() }) {
                        Text(isSigningUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                    }
                }
            }
            .onChange(of: authVM.currentUser, initial: true) { oldUser, newUser in
                if let signedInUser = newUser {
                    userVM.user = signedInUser
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
