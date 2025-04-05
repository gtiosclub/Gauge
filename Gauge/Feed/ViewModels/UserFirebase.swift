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
    @Published var user: User
    // = User(userId: "exampleUser", username: "exampleUser", email: "exuser@gmail.com")
    
    init() {
        self.user = User(userId: "exampleUser", username: "exampleUser", email: "exuser@gmail.com")
    }
    
    func replaceCurrentUser(user: User) {
        self.user = user
    }
    
    func getUserData(userId: String, setCurrentUserData: Bool = false) async throws -> User {
        let document = try await Firebase.db.collection("USERS").document(userId).getDocument()
        
        guard let data = document.data() else {
            throw NSError(domain: "getUserData", code: 404, userInfo: [NSLocalizedDescriptionKey: "User document not found"])
        }

        let userObj = User(
            userId: document.documentID,
            username: data["username"] as? String ?? "",
            phoneNumber: data["phoneNumber"] as? String ?? "",
            email: data["email"] as? String ?? "",
            friendIn: data["friendIn"] as? [String: [String]] ?? [:],
            friendOut: data["friendOut"] as? [String: [String]] ?? [:],
            friends: data["friends"] as? [String: [String]] ?? [:],
            myNextPosts: data["myNextPosts"] as? [String] ?? [],
            myPostSearches: data["myPostSearches"] as? [String] ?? [],
            myProfileSearches: data["myProfileSearches"] as? [String] ?? [],
            myCategories: data["myCategories"] as? [String] ?? [],
            badges: data["badges"] as? [String] ?? [],
            streak: data["streak"] as? Int ?? 0,
            profilePhoto: data["profilePhoto"] as? String ?? "",
            myAccessedProfiles: data["myAccessedProfiles"] as? [String] ?? [],
            lastLogin: DateConverter.convertStringToDate(data["lastLogin"] as? String ?? "") ?? Date(),
            lastFeedRefresh: DateConverter.convertStringToDate(data["lastFeedRefresh"] as? String ?? "") ?? Date()
        )
        
        if setCurrentUserData {
            user.userId = userObj.userId
            user.username = userObj.username
            user.phoneNumber = userObj.phoneNumber
            user.email = userObj.email
            user.friendIn = userObj.friendIn
            user.friendOut = userObj.friendOut
            user.friends = userObj.friends
            user.myNextPosts = userObj.myNextPosts
            user.myPostSearches = userObj.myPostSearches
            user.myProfileSearches = userObj.myProfileSearches
            user.myCategories = userObj.myCategories
            user.badges = userObj.badges
            user.streak = userObj.streak
            user.profilePhoto = userObj.profilePhoto
            user.myAccessedProfiles = userObj.myAccessedProfiles
            user.lastLogin = userObj.lastLogin
            user.lastFeedRefresh = userObj.lastFeedRefresh
        }
        
        return userObj
    }
    
    func getUserPostInteractions(userId: String, setCurrentUserData: Bool = false) async throws -> ([String], [String], [String]) {
        var responsePostIDs: [String] = []
        var commentPostIDs: [String] = []
        var viewPostIDs: [String] = []

        print("Searching for interactions for user: \(user.userId)")

        let postsSnapshot = try await Firebase.db.collection("POSTS").getDocuments()
        let subcollections = ["RESPONSES", "COMMENTS", "VIEWS"]

        for document in postsSnapshot.documents {
            let documentRef = Firebase.db.collection("POSTS").document(document.documentID)

            try await withThrowingTaskGroup(of: (String, String?).self) { group in
                for subcollection in subcollections {
                    group.addTask {
                        let subSnapshot = try await documentRef.collection(subcollection)
                            .whereField("userId", isEqualTo: userId)
                            .getDocuments()

                        if !subSnapshot.documents.isEmpty {
                            return (document.documentID, subcollection)
                        } else {
                            return (document.documentID, nil)
                        }
                    }
                }

                for try await (docID, sub) in group {
                    guard let sub = sub else { continue }
                    switch sub {
                    case "RESPONSES":
                        responsePostIDs.append(docID)
                    case "COMMENTS":
                        commentPostIDs.append(docID)
                    case "VIEWS":
                        viewPostIDs.append(docID)
                    default:
                        break
                    }
                }
            }
        }

        print("Responses: \(responsePostIDs)")
        print("Comments: \(commentPostIDs)")
        print("Views: \(viewPostIDs)")
        
        if setCurrentUserData {
            user.myResponses = responsePostIDs
            user.myViews = viewPostIDs
            user.myComments = commentPostIDs
        }
        
        return (responsePostIDs, commentPostIDs, viewPostIDs)
    }
    
    func getUserPosts(userId: String, setCurrentUserData: Bool = false) async throws -> [String] {
        let snapshot = try await Firebase.db.collection("POSTS")
            .whereField("userId", isEqualTo: userId)
            .getDocuments()

        var postIds: [String] = []

        for document in snapshot.documents {
            print("processing doc")
            postIds.append(document.documentID)
        }

        if setCurrentUserData {
            user.myPosts = postIds
        }
        
        return postIds
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
    
    func getUserFavorites(userId: String, setCurrentUserData: Bool = false) async throws -> [String] {
        let snapshot = try await Firebase.db.collection("POSTS")
            .whereField("favoritedBy", arrayContains: userId)
            .getDocuments()

        var allFavoritePosts: [String] = []

        for document in snapshot.documents {
            allFavoritePosts.append(document.documentID)
        }
        
        if setCurrentUserData {
            user.myFavorites = allFavoritePosts
        }
        
        return allFavoritePosts
    }

    //calculate how many views a users post has
    func getUserNumViews(userId: String, setCurrentUserData: Bool = false) async throws -> Int {
        var totalViews = 0

        // Get all posts by the user
        let postSnapshot = try await Firebase.db.collection("POSTS")
            .whereField("userId", isEqualTo: userId)
            .getDocuments()

        if postSnapshot.documents.isEmpty {
            return 0
        }

        try await withThrowingTaskGroup(of: Int.self) { group in
            for document in postSnapshot.documents {
                let postRef = Firebase.db.collection("POSTS").document(document.documentID)

                group.addTask {
                    let viewsSnapshot = try await postRef.collection("VIEWS").getDocuments()
                    return viewsSnapshot.documents.count
                }
            }

            for try await viewCount in group {
                totalViews += viewCount
            }
        }
        
        if setCurrentUserData {
            user.numUserViews = totalViews
        }
        
        return totalViews
    }
    
    func getUserNumResponses(userId: String, setCurrentUserData: Bool = false) async throws -> Int {
        var totalResponses = 0

        // Get all posts by the user
        let postSnapshot = try await Firebase.db.collection("POSTS")
            .whereField("userId", isEqualTo: userId)
            .getDocuments()

        if postSnapshot.documents.isEmpty {
            return 0
        }

        try await withThrowingTaskGroup(of: Int.self) { group in
            for document in postSnapshot.documents {
                let postRef = Firebase.db.collection("POSTS").document(document.documentID)

                group.addTask {
                    let responsesSnapshot = try await postRef.collection("RESPONSES").getDocuments()
                    return responsesSnapshot.documents.count
                }
            }

            for try await responseCount in group {
                totalResponses += responseCount
            }
        }
        
        if setCurrentUserData {
            user.numUserResponses = totalResponses
        }
        
        return totalResponses
    }
    
    func getUserResponseToViewRatio(userId: String, isForCurrentUser: Bool = false) async throws -> Float {
        if isForCurrentUser {
            return Float(user.numUserResponses) / Float(user.numUserViews)
        } else {
            let numResponses = try await getUserNumResponses(userId: userId, setCurrentUserData: false)
            let numViews = try await getUserNumViews(userId: userId, setCurrentUserData: false)
            
            return Float(numResponses) / Float(numViews)
        }
    }
    
    func setUserCategories(userId: String, category: [Category]) {
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
                    "myPostSearches": user.myPostSearches,
                    "myProfileSearches": user.myProfileSearches,
                    "myAccessedProfiles": user.myAccessedProfiles
                    
        ] as [String : Any]
        
        Firebase.db.collection("USERS").document(user.userId).updateData(data) { error in
            if let error = error {
                print("DEBUG: Failed to updateUserFields from UserFirebase class \(error.localizedDescription)")
                return
            }
        }
    }
    
    func addUserPostSearch(search: String) {
        // Update user var
        user.myPostSearches.append(search)
        
        // Update Firebase
        let userRef = Firebase.db.collection("USERS").document(user.userId)
        userRef.updateData([
            "myPostSearches": FieldValue.arrayUnion([search])
        ])
    }
    
    func addUserProfileSearch(search: String) {
        // Update user var
        user.myProfileSearches.append(search)
        
        // Update Firebase
        let userRef = Firebase.db.collection("USERS").document(user.userId)
        userRef.updateData([
            "myProfileSearches": FieldValue.arrayUnion([search])
        ])
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
        
        Task {
            do {
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
                
                
            } catch {
                print("Error fetching reordered categories: \(error.localizedDescription)")
                completion([])
            }
        }
    }
}
