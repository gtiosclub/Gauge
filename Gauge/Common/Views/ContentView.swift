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
                        
                        ProfileView(userVM: userVM, isCurrentUser: true)
                            .environmentObject(authVM)
                            .tabItem {
                                  Image(systemName: "person.crop.circle")
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
                        
                        print("navigated to the main view")
                    }
                } else {
                    OnboardingView()
                        .environmentObject(authVM)
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
                        async let userNumViews = userVM.getUserNumViews(userId: signedInUser.userId, setCurrentUserData: true)
                        async let userNumResponses = userVM.getUserNumResponses(userId: signedInUser.userId, setCurrentUserData: true)
                        do {
                            _ = try await userData
                            if let userResponse = userResponses.first {
                                let newCategories = userVM.user.myCategories
                                if Set(newCategories) != Set(userResponse.currentUserCategories) {
                                    userResponse.currentUserCategories = newCategories
                                    print("Replaced UserResponses current categories with: " + String(describing: newCategories))
                                    try modelContext.save()
                                }

                                let newTopics = userVM.user.myTopics
                                if Set(newTopics) != Set(userResponse.currentUserTopics) {
                                    userResponse.currentUserTopics = newTopics
                                    print("Replaced UserResponses current topics with: " + String(describing: newTopics))
                                }
                            }
                                                        
                            await postVM.loadFeedPosts(for: userVM.user.myNextPosts)
                            postVM.watchForCurrentFeedPostChanges()
                            
                            _ = try await (
                                userInteractions,
                                userPosts
                            )
                            
                            await postVM.loadInitialNewPosts(user: userVM.user)
                            
                            postVM.watchForNewPosts(user: userVM.user)
                            
                            var queriedHasPostsLeft = true
                            while postVM.feedPosts.count < 5 && queriedHasPostsLeft {
                                queriedHasPostsLeft = postVM.findNextPost(user: userVM.user)
                            }
                            
                            _ = try await (
                                userNumViews,
                                userNumResponses,
                                userFavorites
                            )
                            
                            async let updateNextPosts: () = userVM.updateUserNextPosts(userId: userVM.user.userId, postIds: postVM.feedPosts.map { $0.postId })
                            
                            async let updateStreakAndLogin: () = userVM.updateUserStreakAndLastLogin(user: userVM.user)
                            
                            _ = try await (
                                updateStreakAndLogin,
                                updateNextPosts
                            )
                        } catch {
                            print("❌ Error loading user data: \(error)")
                        }
                    }
                }
            }
            .task {
                do {
                    // Get or create UserResponses
                    let userResponse: UserResponses
                    if !userResponses.isEmpty {
                        print("📱 Found existing UserResponses: \(userResponses.count)")
                        userResponse = userResponses.first!
                        
                        if !userResponse.userCategoryResponses.isEmpty {
                            // Process and reorder based on existing data
                            let newCategories = try await userVM.reorderUserCategory(
                                latest: userResponse.userCategoryResponses,
                                currentInterestList: userResponse.currentUserCategories
                            )
                            
                            print("Categories updated to \(newCategories) from \(userResponse.currentUserCategories)")
                            
                            let isValid = userVM.isValidCategoryReordering(old: userResponse.currentUserCategories, new: newCategories)
                            userResponse.currentUserCategories = isValid
                                ? userResponse.currentUserCategories
                                : newCategories
                            
                            userResponse.userCategoryResponses = [:]
                            
                            if isValid {
                                userVM.user.myCategories = newCategories
                                userVM.setUserCategories(userId: userVM.user.id, category: Category.mapStringsToCategories(returnedStrings: newCategories))
                            }
                            
                            try modelContext.save()
                        } else {
                            print("⚠️ No category interactions to process")
                        }
                        // Process topic interactions if there are any
                        if !userResponse.userTopicResponses.isEmpty {
                            // Process and reorder based on existing data
                            let newTopics = try await userVM.reorderUserTopics(
                                latest: userResponse.userTopicResponses,
                                currentInterestList: userResponse.currentUserTopics
                            )
                            
                            print("Topics updated to \(newTopics) from \(userResponse.currentUserTopics)")
                            
                            userResponse.currentUserTopics = newTopics.isEmpty
                                ? userResponse.currentUserTopics
                                : newTopics
                            
                            userResponse.userTopicResponses = [:]
                            
                            if !newTopics.isEmpty {
                                userVM.user.myTopics = newTopics
                                userVM.setUserTopics(userId: userVM.user.id, topics: newTopics)

                            }
                            
                            try modelContext.save()
                        } else {
                            print("⚠️ No topic interactions to process")
                        }
                    } else {
                        print("⚠️ No UserResponses found. Creating one.")
                        let newResponse = UserResponses()
                        modelContext.insert(newResponse)
                        try modelContext.save()
                        userResponse = newResponse
                    }
                } catch {
                    print("❌ Error reordering categories: \(error)")
                }
            }
            .environmentObject(authVM)
        }
    }
}

#Preview {
    ContentView()
}
