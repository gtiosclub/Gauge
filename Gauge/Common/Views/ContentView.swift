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
    @EnvironmentObject var postVM: PostFirebase
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
                        
//                        Text("Search")
                        SearchView()
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
                        
//                        Text("Profile")
                        ProfileView()
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
            .onChange(of: authVM.currentUser, initial: true) { oldUser, newUser in
                if let signedInUser = newUser {
                    userVM.user = signedInUser
                }
                // populate the user data
                userVM.updateUserFields(user: userVM.user)
                
                // call watchForNewPosts
                postVM.watchForNewPosts(user: userVM.user)
                // move posts in allQueriedPosts to feedPosts that have a matching ID in the user's myNextPosts (in order)
                postVM.feedPosts = postVM.allQueriedPosts.filter { userVM.user.myNextPosts.contains($0.postId) }
                
                // call the watchForCurrentFeedPostChanges
                postVM.watchForCurrentFeedPostChanges()
                
                // call functions to fill out a user's AI Algo variables
                userVM.getPosts(userId: userVM.user.userId) { posts in
                    userVM.user.myPosts = posts
                }
                userVM.getUserPostInteractions{responsePostIDs, commentPostIDs, viewPostIDs in
                    userVM.user.myResponses = responsePostIDs
                    userVM.user.myComments = commentPostIDs
                    userVM.user.myViews = viewPostIDs
                }
                userVM.getUserFavorites(userId: userVM.user.userId) { favorites in
                    userVM.user.myFavorites = favorites
                }
                
                //ADD FUNCTIONS FOR SEARCH AND ACCESSED

            }
        }
    }
}

#Preview {
    ContentView()
}
