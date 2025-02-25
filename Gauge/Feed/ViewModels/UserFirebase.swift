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
    
    func getUserPostInteractions() {
        // create variables to store subcollection info
        var responsePostIDs: [String] = []
        var commentPostIDs: [String] = []
        var viewPostIDs: [String] = []
        
        // traverse through POSTS collection
        Firebase.db.collection("POSTS").getDocuments { snapshot, error in
            if let documents = snapshot?.documents {
                for document in documents {
                    let documentRef = Firebase.db.collection("POSTS").document(document.documentID)
                    
                    
                    let subcollections = ["RESPONSES", "COMMENTS", "VIEWS"]
                    
                    //traverse through subcollections
                    for subcollection in subcollections {
                        let currentSubcollection = subcollection
                        
                        documentRef.collection(currentSubcollection)
                            .whereField("userId", isEqualTo: self.user.userId)
                            .getDocuments { subSnapshot, subError in
                                
                                if let subDocuments = subSnapshot?.documents, !subDocuments.isEmpty {
                                    if currentSubcollection == "RESPONSES" {
                                        responsePostIDs.append(document.documentID)
                                    } else if currentSubcollection == "COMMENTS" {
                                        commentPostIDs.append(document.documentID)
                                    } else if currentSubcollection == "VIEWS" {
                                        viewPostIDs.append(document.documentID)
                                    }
                                }
                            }
                    }
                }
            }
            
            print("Responses: \(responsePostIDs)")
            print("Comments: \(commentPostIDs)")
            print("Views: \(viewPostIDs)")
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
    
    func setUserCategories(userId: String, category: [Category]){
        print("The function is being called")
        var categoryString :[String] = []
        for cat in category {
            categoryString.append(cat.rawValue)
            
        }
        
        Firebase.db.collection("USERS").document(userId).updateData([
            "myCategories": categoryString
        ]) { error in
            if let error = error {
                print("Error settting user categories: \(error)")
            } else {
                print("successfully set the user categories")
            }
        }
        
    }

    //calculate how many views a users post has
    func getUserNumViews(userId: String, completion: @escaping (Int) -> Void) {
        var totalViews = 0
        var pendingRequests = 0
        
        //Get all user posts
        Firebase.db.collection("POSTS")
            .whereField("userId", isEqualTo: userId) //user specific posts
            .getDocuments { snapshot, error in
                if let documents = snapshot?.documents {
                    if documents.isEmpty {
                        completion(0)
                        return
                    }
                    
                    //create this to track how many posts to traverse thru
                    pendingRequests = documents.count
                    
                    for document in documents {
                        let postId = document.documentID
                        let documentRef = Firebase.db.collection("POSTS").document(postId)
                        
                        // views on each document
                        documentRef.collection("VIEWS")
                            .getDocuments { subSnapshot, subError in
                                if let subDocuments = subSnapshot?.documents {
                                    totalViews += subDocuments.count
                                }
                                
                                pendingRequests -= 1
                                
                                
                                if pendingRequests == 0 {
                                    completion(totalViews)
                                }
                            }
                    }
                } else {
                    completion(0)
                }
            }
    }
    
}
