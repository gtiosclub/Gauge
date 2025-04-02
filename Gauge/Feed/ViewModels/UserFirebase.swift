//
//  UserFirebase.swift
//  Gauge
//
//  Created by Austin Huguenard on 2/6/25.
//

import Foundation
import FirebaseFirestore
import ChatGPTSwift

class UserFirebase: ObservableObject {
    @Published var user: User = User(userId: "exampleUser", username: "exampleUser", email: "exuser@gmail.com")
    
    func getAllUserData(userId: String, completion: @escaping (User) -> Void) {
        Firebase.db.collection("USERS").document(userId).getDocument { document, error in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                if let data = document?.data() {
                    let userObj = User(
                        userId: document!.documentID,
                        username: data["username"] as? String ?? "",
                        phoneNumber: data["phoneNumber"] as? String ?? "",
                        email: data["email"] as? String ?? "",
                        friendIn: data["friendIn"] as? [String: [String]] ?? [:],
                        friendOut: data["friendOut"] as? [String: [String]] ?? [:],
                        friends: data["friends"] as? [String: [String]] ?? [:],
                        myNextPosts: data["myNextPosts"] as? [String] ?? [],
                        myFavorites: data["myFavorites"] as? [String] ?? [],
                        mySearches: data["mySearches"] as? [String] ?? [],
                        myCategories: data["myCategories"] as? [String] ?? [],
                        badges: data["badges"] as? [String] ?? [],
                        streak: data["streak"] as? Int ?? 0,
                        profilePhoto: data["profilePhoto"] as? String ?? "",
                        myAccessedProfiles: data["myAccessedProfiles"] as? [String] ?? [],
                        lastLogin: DateConverter.convertStringToDate(data["lastLogin"] as? String ?? "") ?? Date(),
                        lastFeedRefresh: DateConverter.convertStringToDate(data["lastFeedRefresh"] as? String ?? "") ?? Date()
                    )
                    
                    completion(userObj)
                }
            }
        }
    }
    
    func getUserPostInteractions(completion: @escaping ([String], [String], [String]) -> Void) {
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
                        if(currentSubcollection == "VIEWS") {
                            print("Responses: " + responsePostIDs.joined(separator: ", "))
                            print("Comments: " + commentPostIDs.joined(separator: ", "))
                            print("Views: " + viewPostIDs.joined(separator: ", "))
                            completion(responsePostIDs, commentPostIDs, viewPostIDs)
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
    

    func updateUserFields(user: User) {
        let data = ["lastLogin": DateConverter.convertDateToString(user.lastLogin),
                    "lastFeedRefresh": DateConverter.convertDateToString(user.lastFeedRefresh),
                    "streak": user.streak,
                    "friendIn": user.friendIn,
                    "friendOut": user.friendOut,
                    "friends": user.friends,
                    "badges": user.badges,
                    "profilePhoto": user.profilePhoto,
                    "phoneNumber": user.phoneNumber,
                    "myCategories": user.myCategories,
                    "myNextPosts": user.myNextPosts,
                    "mySearches": user.mySearches,
                    "myAccessedProfiles": user.myAccessedProfiles
                    
        ] as [String : Any]
        
        Firebase.db.collection("USERS").document(user.userId).updateData(data) { error in
            if let error = error {
                print("DEBUG: Failed to updateUserFields from UserFirebase class \(error.localizedDescription)")
                return
            }
        }
    }
    
    func getUsernameAndPhoto(userId: String, completion: @escaping ([String: String]) -> Void) {
        var nameAndPhoto = ["username": "", "profilePhoto": ""]
        
        Firebase.db.collection("USERS").document(userId).getDocument { document, error in
            if let error = error {
                print("Error getting user \(error)")
                return
            }
            
            if let data = document?.data() {
                nameAndPhoto["username"] = data["username"] as? String ?? ""
                nameAndPhoto["profilePhoto"] = data["profilePhoto"] as? String ?? ""
            }
            
            completion(nameAndPhoto)
        }
    }
    
    func getUserFavorites(userId: String, completion: @escaping ([String]) -> Void) {
        // Create an array to store favorite postId
        var allFavoritePosts: [String] = []
        // fetch all documents in the "POSTS" collection
        // that have the "userId" in their "favoriteBy" field
        Firebase.db.collection("POSTS")
            .whereField("favoritedBy", arrayContains: userId)
            .getDocuments { (snapshot, error) in
                if let error = error {
                    print("Error getting favorite posts: \(error)")
                    completion([])
                } else {
                    for document in snapshot!.documents {
                        allFavoritePosts.append(document.documentID)
                    }
                    completion(allFavoritePosts)
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
    
    func getUserNumResponses(postIds: [String]) async -> Int? {
            do {
                var totalResponses = 0
                
                for postId in postIds {
                    let documentRef = Firebase.db.collection("POSTS").document(postId).collection("RESPONSES")
                    let querySnapshot = try await documentRef.getDocuments()
                    let count = querySnapshot.documents.count
                    print("Number of responses under \(postId): \(count)")
                    totalResponses += count
                }
                
                return totalResponses
            } catch {
                print("Error getting responses: \(error)")
                return nil
            }
        }
    
    func getUserResponseToViewRatio(userId: String, completion: @escaping (Double) -> Void) {
        getUserNumViews(userId: userId) { views in
            // get all of user's posts
            Firebase.db.collection("POSTS")
                .whereField("userId", isEqualTo: userId)
                .getDocuments { snapshot, error in
                    if let documents = snapshot?.documents, !documents.isEmpty {
                        let postIds = documents.map { document in
                            return document.documentID
                        }

                        Task {
                            let responses = await self.getUserNumResponses(postIds: postIds) ?? 0
                            let total = responses + views
                            
                            let ratio = total > 0 ? Double(responses) / Double(total) : 0.0
                            completion(ratio)
                        }
                    } else {
                        completion(0.0) // no posts exist, return 0 ratio
                    }
                }
        }
    }
    
    
    func reorderUserCategory(lastest : [String: Int], currentInterestList: [String], completion: @escaping ([String]) -> Void){
            //lastest: given the dictionary of last session of interest category from user
            //currentIntegerList: this is the current category list

            let lastestSorted = lastest.sorted{$0.value > $1.value}
            //get the OpenAI token
            let token = ChatGPTAPI(apiKey:Keys.openAIKey)
            //assigning prompt to the OpenAI
            let prompt:String = """
            I will give you 2 lists, where a dictionary list to store the interests point of the user lastest interactions with the categories, and another list of current catgories. Please based on the significant interest points, what we mean significant is only move the current categories up or down if the interactions make it very apparent the user has interest/disinterest in a category. And need to combine the current category list order which also takes into account of weight. Return the reordered the category list. to better perform this task, sorting the lastest interaction first (I help you sorted already), and remove all the categories that does not consist in the current list, after that reordering based on the point. The returned format would be: [String]. Do not give me any sentence but the string list as a return prompt. Any category that does not exist in the current list do not be included in the return list.
            lastest interaction categories: \(lastestSorted)
            current list of category: \(currentInterestList)
            """

            //making the call
            
            Task{
                do{
                    let response = try await token.sendMessage(text: prompt,
                                                               model: ChatGPTModel.gpt_hyphen_4o_hyphen_mini,
                                                               systemText: "You are a reordering expert",
                                                               temperature: 0.5)
                    
                    if let data = response.data(using: .utf8),
                       let jsonArray = try? JSONDecoder().decode([String].self, from: data) {
                        //return the string list
                        completion(jsonArray)
                    } else {
                        print("Failed to parse OpenAI response")
                        completion([])
                    }
                    
                    
                }catch {
                    print("Error fetching reordered categories: \(error.localizedDescription)")
                    completion([])
                }
                
                
            }
            
            }



}
