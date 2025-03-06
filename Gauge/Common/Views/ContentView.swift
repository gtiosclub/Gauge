//
//  ContentView.swift
//  Gauge
//
//  Created by Datta Kansal on 2/6/25.
//

import SwiftUI

struct ContentView: View {
    @State private var isSigningUp = false
    @State private var authVM = AuthenticationVM()
    
    var body: some View {
        VStack {
//             SearchView() // after commenting everything here
            if isSigningUp {
                SignUpView()
            } else {
                SignInView()
            }
            .background(.red)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showSplashScreen = false
                }
            }
        } else {
            VStack {
                if authVM.currentUser != nil {
                    TabView(selection: $selectedTab) {
                        FeedView()
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
                        
                        GamesHome()
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
                    .onAppear {
                        // correct the transparency bug for Tab bars
                        let tabBarAppearance = UITabBarAppearance()
                        tabBarAppearance.configureWithOpaqueBackground()
                        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
                        // correct the transparency bug for Navigation bars
                        let navigationBarAppearance = UINavigationBarAppearance()
                        navigationBarAppearance.configureWithOpaqueBackground()
                        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
                    }
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
            .onChange(of: authVM.currentUser, initial: false) { oldUser, newUser in
                if let signedInUser = newUser {
                    userVM.user = signedInUser
                }
                // populate the user data
                // call watchForNewPosts
                // move posts in allQueriedPosts to feedPosts that have a matching ID in the user's myNextPosts (in order)
                // call the watchForCurrentFeedPostChanges
                // call functions to fill out a user's AI Algo variables
            }
        }
    }
}

#Preview {
    ContentView()
}
