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
                    Section("Write Data") {
                        Button("Add Binary Post") {
                            postVM.createBinaryPost(
                                userId: "tfeGCRCgt8UbJhCmKgNmuIFVzD73",
                                categories: [.sports(.nfl)],
                                question: "Is pizza the goat food?",
                                responseOption1: "yes",
                                responseOption2: "no"
                            )
                        }
                        
                        Button("Add Slider Post") {
                            postVM.createSliderPost(
                                userId: "austin",
                                categories: [.educational(.cs)],
                                question: "rate Swift 1-10",
                                lowerBoundValue: 1,
                                upperBoundValue: 10,
                                lowerBoundLabel: "Terrible 🤮",
                                upperBoundLabel: "Goated 🐐"
                            )
                        }
                        
                        Button("Add Ranked Post") {
                            postVM.createRankPost(
                                userId: "2lCFmL9FRjhY1v1NMogD5H6YuMV2",
                                categories: [.arts(.music)],
                                question: "Best Half-Time Performance?",
                                responseOptions: ["Kendrick Lamar", "Rihanna", "The Weeknd", "Shakira + J Lo"]
                            )
                        }
                        
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
                        
                        Button("test setUserCategories"){
                            userVM.setUserCategories(userId: "austin", category: [Category.educational(.environment), Category.educational(.math)])
                        }
                    }
                    
                    Section("Read Data") {
                        Button("Get posts by userId") {
                            userVM.getPosts(userId: "tfeGCRCgt8UbJhCmKgNmuIFVzD73") { postIds in
                                self.postIds = postIds
                            }
                        }
                        
                        Button("Add Slider Post") {
                            postVM.createSliderPost(
                                userId: "xEZWt93AaJZPwfHAjlqMjmVP0Lz1",
                                categories: [.educational(.cs)],
                                question: "rate Swift 1-10",
                                lowerBoundValue: 1,
                                upperBoundValue: 10,
                                lowerBoundLabel: "Terrible 🤮",
                                upperBoundLabel: "Goated 🐐"
                            )
                        }
                        
                        Button("Add Ranked Post") {
                            postVM.createRankPost(
                                userId: "2lCFmL9FRjhY1v1NMogD5H6YuMV2",
                                categories: [.arts(.music)],
                                question: "Best Half-Time Performance?",
                                responseOptions: ["Kendrick Lamar", "Rihanna", "The Weeknd", "Shakira + J Lo"]
                            )
                        }
                        
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
                        Button("Get posts by userId") {
                            userVM.getPosts(userId: "tfeGCRCgt8UbJhCmKgNmuIFVzD73") { postIds in
                                self.postIds = postIds
                            }
                            
                            print(postIds.count)
                        }
                        
                        Button("Get all user data by userId") {
                            let user = userVM.getAllUserData(userId: "austin") { user in
                                print(user.username)
                                print(user.badges)
                                print(user.myCategories)
                            }
                        }
                        
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
                        
                        Button("Get number of responses for a list of posts") {
                            Task {
                                if let count = await postVM.getUserNumResponses(postIds: [
                                    "B2A9F081-A10C-4957-A6B8-0295F0C700A2",
                                    "examplePost"
                                ]) {
                                    print("Number of responses: \(count)")
                                } else {
                                    print("Failed to get number of responses")
                                }
                            }
                        }


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
                            userVM.addUserSearch(
                                search: "friends"
                            )
                        }
                        
                        Button("Generate 20 Keywords") {
                            postVM.generatePostKeywords(postId: "B2A9F081-A10C-4957-A6B8-0295F0C700A2")
                        }
                        
                        Button("Remove View") {
                            postVM.removeView(
                                postId: "examplePost",
                                userId: "Jack")
                        }
                    }
                    
                    Section("View Data") {
                        Button("Fetch Favorited Posts") {
                            userVM.getUserFavorites(userId: "ExampleUser")
                        }
                        
                        ForEach(postVM.allQueriedPosts) { post in
                            Text(post.postId)
                        }
                    }
                    
                    Section("OpenAI Queries") {
                        Button("Suggest Post Categories") {
                            postVM.suggestPostCategories(
                                question: "Which channel is better?", responseOptions: ["National Geographic", "Animal Planet"]
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
