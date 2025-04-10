//
//  FirebaseTesting.swift
//  Gauge
//
//  Created by Austin Huguenard on 2/10/25.
//

import SwiftUI

struct FirebaseTesting: View {
    @EnvironmentObject var postVM: PostFirebase
    @EnvironmentObject var userVM: UserFirebase
    @State private var postIds: [String] = []
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Section(header: Text("Write Data")) {
                        Button("Add Binary Post") {
                            Task {
                                await postVM.createBinaryPost(
                                    userId: "Zmi5Cgm7dtbqCDbLOrhbbDAq8T92",
                                    categories: [.sports(.nba)],
                                    question: "Is Shai the MVP",
                                    responseOption1: "No",
                                    responseOption2: "Yes",
                                    sublabel1: "Nah, free throw merchant🙅‍♂️",
                                    sublabel2: "Stats dont lie"
                                )
                            }
                        }
                        
                        
                        Button("Date Score Tester") {
                            let yodate = DateConverter.convertStringToDate("2025-04-01 17:42:22") ?? Date()
                            print(DateConverter.calcDateScore(postDate: yodate))
                        }
                        
                        Button("Add Slider Post") {
                            Task {
                                await
                                postVM.createSliderPost(
                                    userId: "austin",
                                    categories: [.educational(.cs)],
                                    question: "rate Swift 1-10",
                                    lowerBoundLabel: "Terrible 🤮",
                                    upperBoundLabel: "Goated 🐐"
                                )
                            }
                        }
                        
//                        Button("Add Ranked Post") {
//                            postVM.createRankPost(
//                                userId: "2lCFmL9FRjhY1v1NMogD5H6YuMV2",
//                                categories: [.arts(.music)],
//                                question: "Best Half-Time Performance?",
//                                responseOptions: ["Kendrick Lamar", "Rihanna", "The Weeknd", "Shakira + J Lo"]
//                            )
//                        }
                        
                        Button("Add user to VIEWS of a post (hardcoded for Firebase testing)") {
                            postVM.addViewToPost(
                                postId: "B2A9F081-A10C-4957-A6B8-0295F0C700A2",
                                userId: "2lCFmL9FRjhY1v1NMogD5H6YuMV2"
                            )
                        }
                        
                        Button("Add response") {
                            postVM.addResponse(
                                postId: "examplePost",
                                userId: "exampleUser",
                                responseOption: "Chocolate"
                            )
                        }
                        
                        Button("Test reordering for category") {
                            let lastest: [String: Int] = [
                                "nfl": 120,
                                "movies": 250,
                                "education": 20,
                                "showReccomendations": 30
                            ]
                            
                            let currentInterestList: [String] = [
                                "showRecommendations",
                                "education",
                                "movies"
                            ]
                            
                            Task {
                                do {
                                    let reorderList = try await userVM.reorderUserCategory(
                                        latest: lastest,
                                        currentInterestList: currentInterestList
                                    )
                                    print("This is the reordered list based on the input: \(reorderList)")
                                } catch {
                                    print("❌ Error reordering categories: \(error)")
                                }
                            }
                        }
                        
                        Button("test setUserCategories"){
                            userVM.setUserCategories(userId: "austin", category: [Category.educational(.environment), Category.educational(.math)])
                        }
                    }
                    
                    Section("Read Data") {
//                        Button("Get posts by userId") {
//                            userVM.getPosts(userId: "tfeGCRCgt8UbJhCmKgNmuIFVzD73") { postIds in
//                                self.postIds = postIds
//                            }
//                        }
                        
//                        Button("Add Ranked Post") {
//                            postVM.createRankPost(
//                                userId: "2lCFmL9FRjhY1v1NMogD5H6YuMV2",
//                                categories: [.arts(.music)],
//                                question: "Best Half-Time Performance?",
//                                responseOptions: ["Kendrick Lamar", "Rihanna", "The Weeknd", "Shakira + J Lo"]
//                            )
//                        }
                        
                        Button("Add response") {
                            postVM.addResponse(
                                postId: "examplePost",
                                userId: "exampleUser",
                                responseOption: "Vanilla"
                            )
                        }
                    }
                    
                    Section("Get Live Data (Great for feed & games!)") {
                        Button("Watch for Posts") {
                            postVM.watchForNewPosts(user: userVM.user)
                        }
                    }
                    
                    Section(header: Text("Read Data")) {
//                        Button("Get posts by userId") {
//                            userVM.getPosts(userId: "tfeGCRCgt8UbJhCmKgNmuIFVzD73") { postIds in
//                                self.postIds = postIds
//                            }
//                            
//                            print(postIds.count)
//                        }
//                        
//                        Button("Get all user data by userId") {
//                            let user = userVM.getAllUserData(userId: "austin") { user in
//                                print(user.username)
//                                print(user.badges)
//                                print(user.myCategories)
//                            }
//                        }
                        
                        Button("Get response results from a post") {
                            postVM.getResponses(postId: "examplePost") { results in
                                print(results)
                            }
                        }
                        
                        Button("Get username and profile picture") {
                            userVM.getUsernameAndPhoto(userId: "Lv72Qz7Qc4TC2vDeE94q") { object in
                                print(object)
                            }
                        }
                        
//                        Button("Get number of responses for a list of posts") {
//                            Task {
//                                let count = try await userVM.getUserNumResponses(userId: "Rzqik2ISWBezcmBVVaoCbR4rCz92")
//                                if count >= 0 {
//                                    print("Number of responses: \(count)")
//                                } else {
//                                    print("Failed to get number of responses")
//                                }
//                            }
//                        }


                    }
                    
                    Section("Update Data") {
                        Button("Like Comment") {
                            postVM.likeComment(
                                postId: "examplePost",
                                commentId: "Ge3KON8x7l1jUUlpRvd7",
                                userId: "Jack")
                        }
                        
                        Button("Dislike Comment") {
                            postVM.dislikeComment(
                                postId: "examplePost",
                                commentId: "Ge3KON8x7l1jUUlpRvd7",
                                userId: "Jack")
                        }
                        
                        Button("Update User Austin") {
                            let updatedUser = User(userId: "austin", username: "Austin", email: "austin@example.com")
                            updatedUser.phoneNumber = "999-999-9999" // Example new phone number
                            updatedUser.streak = 5
                            updatedUser.badges = ["Gold", "Platinum"]
                            
                            userVM.updateUserFields(user: updatedUser)
                        }
                        
                        Button("Update post favorited by (add user)") {
                            postVM.addUserToFavoritedBy(
                                postId: "B2A9F081-A10C-4957-A6B8-0295F0C700A2",
                                userId: "2lCFmL9FRjhY1v1NMogD5H6YuMV2"
                            )
                        }
                        
                        Button("Update user searches (add)") {
                            userVM.addUserPostSearch(
                                search: "friends"
                            )
                        }
                        
//                        Button("Generate 20 Keywords") {
//                            postVM.generatePostKeywords(postId: "B2A9F081-A10C-4957-A6B8-0295F0C700A2")
//                        }
                        
                        Button("Remove View") {
                            postVM.removeView(
                                postId: "examplePost",
                                userId: "Jack")
                        }
                    }
                    
                    Section("View Data") {
//                        Button("Fetch Favorited Posts") {
//                            userVM.getUserFavorites(userId: "ExampleUser"){ favorites in }
//                        }
                        
                        ForEach(postVM.allQueriedPosts, id: \.postId) { post in
                            Text(post.postId)
                        }
                    }
                    
                    Section("OpenAI Queries") {
                        Button("Suggest Post Categories") {
                            postVM.suggestPostCategories(
                                question: "Which channel is better?", captions: ["National Geographic", "Animal Planet"]
                            ) { suggestedCategories in
                                print(suggestedCategories)
                            }
                        }
                    }
                }
            }
            .onAppear {
                print(postVM.allQueriedPosts)
            }
        }
    }
}

#Preview {
    FirebaseTesting()
        .environmentObject(PostFirebase())
        .environmentObject(UserFirebase())
}
