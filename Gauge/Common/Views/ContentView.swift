//
//  ContentView.swift
//  Gauge
//
//  Created by Datta Kansal on 2/6/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @StateObject private var authVM = AuthenticationVM()
    @EnvironmentObject var userVM: UserFirebase
    @EnvironmentObject var postVM: PostFirebase
    @State private var isSigningUp = false
    @State private var selectedTab: Int = 0
    @State private var showSplashScreen: Bool = true
    @Environment(\.modelContext) private var modelContext
    @Query var userResponses: [UserResponses]
    
    var body: some View {
        if showSplashScreen {
            ZStack {
                Color.red

                Image(systemName: "gauge.open.with.lines.needle.84percent.exclamation")
                    .resizable()
                    .scaledToFit()
                    .frame(width: UIScreen.main.bounds.width - 50)
            }
            .ignoresSafeArea()
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
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
                    userVM.replaceCurrentUser(user: signedInUser)
                    
                    print("Signed in as user: " + signedInUser.userId)
                    
                    Task {
                        async let userData = userVM.getUserData(userId: signedInUser.userId, setCurrentUserData: true)
                        async let userInteractions = userVM.getUserPostInteractions(userId: signedInUser.userId, setCurrentUserData: true)
                        async let userPosts = userVM.getUserPosts(userId: signedInUser.userId, setCurrentUserData: true)
                        async let userFavorites = userVM.getUserFavorites(userId: signedInUser.userId, setCurrentUserData: true)
                        async let userViews = userVM.getUserNumViews(userId: signedInUser.userId, setCurrentUserData: true)
                        async let userResponses = userVM.getUserNumResponses(userId: signedInUser.userId, setCurrentUserData: true)
                        
                        do {
                            _ = try await userData
                            
                            await postVM.loadFeedPosts(for: userVM.user.myNextPosts)
                            postVM.watchForCurrentFeedPostChanges()
                            
                            _ = try await (
                                userInteractions,
                                userPosts
                            )
                            
                            await postVM.loadInitialNewPosts(user: userVM.user)
                            
                            postVM.watchForNewPosts(user: userVM.user)
                            
                            while postVM.feedPosts.count < 5 {
                                postVM.findNextPost(user: userVM.user)
                            }
                            
                            _ = try await (
                                userViews,
                                userResponses,
                                userFavorites
                            )
                        } catch {
                            print("❌ Error loading user data: \(error)")
                        }
                    }
                }
            }
            .task {
                do {
                    let userResponse: UserResponses
                    if let existing = userResponses.first {
                        userResponse = existing
                    } else {
                        print("⚠️ No UserResponses found. Creating one.")
                        let newResponse = UserResponses()
                        modelContext.insert(newResponse)
                        userResponse = newResponse
                    }
                    
                    let newCategories = try await userVM.reorderUserCategory(
                        latest: userResponse.userCategoryResponses,
                        currentInterestList: userResponse.currentUserCategories
                    )
                    
                    userResponse.currentUserCategories = newCategories.isEmpty
                    ? userResponse.currentUserCategories
                    : newCategories
                    
                    userResponse.userCategoryResponses = [:]
                    
                    /*
                     let newTopics = try await userVM.reorderUserTopics(
                     latest: userResponse.userTopicResponses,
                     currentInterestList: userResponse.currentUserTopics
                     )
                     
                     userResponse.currentUserTopics = newTopics.isEmpty
                     ? userResponse.currentUserTopics
                     : newTopics
                     
                     userResponse.userTopicResponses = [:]
                     */
                    
                } catch {
                    print("❌ Error reordering categories: \(error)")
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
