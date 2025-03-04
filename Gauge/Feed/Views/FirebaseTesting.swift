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
                        responseOption: "Chocolate"
                        )
                }
            }
            
            Section("Get Live Data (Great for feed & games!)") {
                Button("Watch for Posts") {
                    postVM.getLiveFeedPosts(user: userVM.user)
                }
            }
            
            Section("Read Data") {
                Button("Get posts by userId") {
                    userVM.getPosts(userId: "tfeGCRCgt8UbJhCmKgNmuIFVzD73") { postIds in
                        self.postIds = postIds
                    }
                    
                    print(postIds.count)
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
            }
            
            Section("View Data") {
                Button("Fetch Favorited Posts") {
                    userVM.getUserFavorites(
                        userId: "ExampleUser")
                }
            }
        }
        .onAppear() {
            print("\(Keys.openAIKey)")
        }
    }
}

#Preview {
    FirebaseTesting()
        .environmentObject(PostFirebase())
        .environmentObject(UserFirebase())
}
