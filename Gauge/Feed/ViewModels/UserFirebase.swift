//
//  UserFirebase.swift
//  Gauge
//
//  Created by Austin Huguenard on 2/6/25.
//

import Foundation
import FirebaseFirestore

class UserFirebase: ObservableObject {
    @Published var user: User = User(userId: "exampleUser", username: "exampleUser", email: "exuser@gmail.com")
    
    func getAllUserData(userId: String, completion: @escaping (User) -> Void) {
        Firebase.db.collection("USERS").document(userId).getDocument { document, error in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                if let data = document?.data() {
                    let userObj = User(
                        userId: data["userId"] as? String ?? "",
                        username: data["username"] as? String ?? "",
                        phoneNumber: data["phoneNumber"] as? String ?? "",
                        email: data["email"] as? String ?? "",
                        friendIn: data["friendIn"] as? [String: [String]] ?? [:],
                        friendOut: data["friendOut"] as? [String: [String]] ?? [:],
                        friends: data["friends"] as? [String: [String]] ?? [:],
                        myPosts: data["myPosts"] as? [String] ?? [],
                        myResponses: data["myResponses"] as? [String] ?? [],
                        myFavorites: data["myFavorites"] as? [String] ?? [],
                        mySearches: data["mySearches"] as? [String] ?? [],
                        myComments: data["myComments"] as? [String] ?? [],
                        myCategories: data["myCategories"] as? [String] ?? [],
                        badges: data["badges"] as? [String] ?? [],
                        streak: data["streak"] as? Int ?? 0
                    )
                    
                    completion(userObj)
                }
            }
        }
    }
    
    func addUserSearch(search: String) {
        // Update user var
        user.mySearches.append(search)
        
        // Update Firebase
        let userRef = Firebase.db.collection("USERS").document(user.userId)
        userRef.updateData([
            "mySearches": FieldValue.arrayUnion([search])
        ])
    }
    
    func getPosts(userId: String, completion: @escaping ([String]) -> Void) {
        var postIds: [String] = []
        
        Firebase.db.collection("POSTS")
            .whereField("userId", isEqualTo: userId)
            .getDocuments { (snapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                } else {
                    for document in snapshot!.documents {
                        print("processing doc")
                        postIds.append(document.documentID)
                    }
                    
                    completion (postIds)
                }
            }
    }
    
    //let attributesList = ["lastLogin", "lastFeedRefresh", "streak", "friendIn", "friendOut", "friends", "badges", "profilePhoto", "phoneNumber", "myCategories", "myNextPosts", "mySearches", "myAccessedProfiles"]
    

    func updateUserFields(user: User){
        let data = ["lastLogin": user.lastLogin,
                    "lastFeedRefresh": user.lastFeedRefresh,
                    "streak":user.streak,
                    "friendIn":user.friendIn,
                    "friendOut":user.friendOut,
                    "friends":user.friends,
                    "badges": user.badges,
                    "profilePhoto":user.profilePhoto,
                    "phoneNumber":user.phoneNumber,
                    "myCategories":user.myCategories,
                    "myNextPosts":user.myNextPosts,
                    "mySearches":user.mySearches,
                    "myAccessedProfiles": user.myAccessedProfiles
                    
        ] as [String : Any]
        
        Firebase.db.collection("USERS").document(user.userId).updateData(data) { error in
            if let error = error {
                print("DEBUG: Failed to updateUserFields from UserFirebase class \(error.localizedDescription)")
                return
            }
        }
    }
    
    func getUserFavorites(userId: String) {
        // Create an array to store favorite postId
        var allFavoritePosts: [String] = []
        // fetch all documents in the "POSTS" collection
        // that have the "userId" in their "favoriteBy" field
        Firebase.db.collection("POSTS")
            .whereField("favoritedBy", arrayContains: userId)
            .getDocuments { (snapshot, error) in
                if let error = error {
                    print("Error getting favorite posts: \(error)")
                } else {
                    for document in snapshot!.documents {
                        allFavoritePosts.append(document.documentID)
                    }
                }
            }
    }
}
