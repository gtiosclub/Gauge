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
            myTopics: data["myTopics"] as? [String] ?? [],
            badges: data["badges"] as? [String] ?? [],
            streak: data["streak"] as? Int ?? 0,
            profilePhoto: data["profilePhoto"] as? String ?? "",
            myAccessedProfiles: data["myAccessedProfiles"] as? [String] ?? [],
            lastLogin: DateConverter.convertStringToDate(data["lastLogin"] as? String ?? "") ?? Date(),
            lastFeedRefresh: DateConverter.convertStringToDate(data["lastFeedRefresh"] as? String ?? "") ?? Date(),
            attributes: data["attributes"] as? [String: String] ?? [:]
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
            user.attributes = userObj.attributes
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
    
    func updateUserFields(user: User) {
        let data = [
            "lastLogin": DateConverter.convertDateToString(user.lastLogin),
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
            "myProfileSearches": user.myProfileSearches,
            "myPostSearches": user.myPostSearches,
            "myAccessedProfiles": user.myAccessedProfiles,
            "attributes": user.attributes,
            "myPosts": user.myPosts,
            "myResponses": user.myResponses,
            "myViews": user.myViews,
            "myComments": user.myComments,
            "numUserResponses": user.numUserResponses,
            "numUserViews": user.numUserViews
        ] as [String : Any]
        
        Firebase.db.collection("USERS").document(user.userId).updateData(data) { error in
            if let error = error {
                print("DEBUG: Failed to updateUserFields from UserFirebase class \(error.localizedDescription)")
                return
            }
        }
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
  
    // reorder user's topic using OpenAI
    func reorderUserTopics(for user: User, with interactions: [String: Int]) {
        let db = Firestore.firestore()
        let userRef = db.collection("USERS").document(user.userId)
        
        let currentTopics = user.myTopics
        
        // Format the interactions dictionary into a string for the OpenAI prompt
        let interactionPairs = interactions.map { "\"\($0)\": \($1)" }.joined(separator: ", ")
        let interactionsString = "{\(interactionPairs)}"
        
        let examplePrompt = """
                Given the user's current topic list and their most recent interaction counts per topic, reorder the list so that the most relevant topics appear higher. Be **conservative**—only rearrange topics significantly if the interaction data clearly shows strong interest or disinterest.

                - Always return exactly **20** topics.
                - Topics may be added or removed at your discretion if needed for relevance.
                - Index 0 = highest interest, index 19 = lowest.
                - Return only a JSON list of 20 topic strings, no explanations.

                Example:
                Current Topics: ["AI", "Gaming", "Fitness", "Politics", "NFL", "Cooking", "Stocks", "Movies", "Fashion", "Travel", "NBA", "Music", "Photography", "Books", "Science", "Education", "Food", "Space", "Health", "History"]
                Last Session Interactions: {"NFL": 14, "NBA": 13, "Gaming": 11, "AI": 2, "Books": 0, "Fashion": 1, "Science": 5, "Music": 6, "Politics": 0}
                Output:
                ["NFL", "NBA", "Gaming", "Music", "Science", "AI", "Cooking", "Fitness", "Stocks", "Movies", "Travel", "Photography", "Education", "Food", "Space", "Health", "Fashion", "History", "Politics", "Books"]

                Now reorder this list:
                Current Topics: \(currentTopics)
                Last Session Interactions: \(interactionsString)
                Output:
                """
        
        let openAIRequest: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                ["role": "system", "content": "You are an assistant that helps personalize topic rankings for users based on session activity. Respond ONLY with a JSON list of 20 topic strings."],
                ["role": "user", "content": examplePrompt]
            ],
            "temperature": 0.4
        ]
        
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            print("Invalid OpenAI URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(Keys.openAIKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: openAIRequest, options: [])
        } catch {
            print("Failed to encode OpenAI request")
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("OpenAI API error: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("No data received from OpenAI")
                return
            }

            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let choices = jsonResponse["choices"] as? [[String: Any]],
                   let text = choices.first?["message"] as? [String: Any],
                   let content = text["content"] as? String {
                    
                    guard let reorderedData = content.data(using: .utf8),
                          let reorderedTopics = try JSONSerialization.jsonObject(with: reorderedData, options: []) as? [String],
                          reorderedTopics.count == 20 else {
                        print("Invalid or incomplete topic list returned")
                        return
                    }

                    DispatchQueue.main.async {
                        user.myTopics = reorderedTopics
                    }

                    // Save to Firestore
                    userRef.updateData(["myTopics": reorderedTopics]) { error in
                        if let error = error {
                            print("Failed to update reordered topics: \(error.localizedDescription)")
                        } else {
                            print("User topics successfully reordered and updated")
                        }
                    }
                } else {
                    print("Unexpected OpenAI response format")
                }
            } catch {
                print("Failed to decode OpenAI response: \(error.localizedDescription)")
            }
        }
        
        task.resume()
    }

    func reorderUserCategory(latest: [String: Int], currentInterestList: [String]) async throws -> [String] {
        let latestSorted = latest.sorted { $0.value > $1.value }

        let prompt = """
        I will give you 2 lists: a dictionary of the user's latest category interactions, and a list of current categories. Based on significant interaction scores, reorder the current categories only if the data clearly shows preference or disinterest. Combine the sorted interactions with the current list's original order and weight.

        Only include categories that exist in the current list. Return just a Swift array of strings in this format: ["Category1", "Category2", ...] — no extra explanation or formatting.

        Latest interaction categories: \(latestSorted)
        Current category list: \(currentInterestList)
        """

        let token = ChatGPTAPI(apiKey: Keys.openAIKey)

        do {
            let response = try await token.sendMessage(
                text: prompt,
                model: ChatGPTModel.gpt_hyphen_4o_hyphen_mini,
                systemText: "You are a reordering expert",
                temperature: 0.5
            )

            guard let data = response.data(using: .utf8) else {
                print("⚠️ Could not convert response to UTF-8 data")
                return []
            }

            do {
                let decoded = try JSONDecoder().decode([String].self, from: data)
                return decoded
            } catch {
                print("⚠️ Failed to decode JSON: \(error)")
                return []
            }
        } catch {
            print("❌ OpenAI API error: \(error)")
            return []
        }
    }
    
    func updateUserStreakAndLastLogin(user: User) async throws {
        let hoursSinceLastLogin = Date().timeIntervalSince(user.lastLogin) / 3600
        
        if hoursSinceLastLogin > 48 {
            // Reset streak
            let now = Date()
            let updatedData: [String: Any] = [
                "lastLogin": DateConverter.convertDateToString(now),
                "streak": 1
            ]
            try await Firebase.db.collection("USERS").document(user.userId).updateData(updatedData)
            print("🔁 Streak reset to 1 and lastLogin updated.")
            
        } else if hoursSinceLastLogin > 24 {
            // Increment streak
            let now = Date()
            let updatedData: [String: Any] = [
                "lastLogin": DateConverter.convertDateToString(now),
                "streak": user.streak + 1
            ]
            try await Firebase.db.collection("USERS").document(user.userId).updateData(updatedData)
            print("🔥 Streak incremented and lastLogin updated.")
            
        }
    }
    
    func updateUserNextPosts(userId: String, postIds: [String]) async throws {        
        let data: [String: Any] = [
            "myNextPosts": postIds
        ]

        try await Firebase.db.collection("USERS").document(userId).updateData(data)
        print("✅ myNextPosts updated for user \(userId)")
    }
}
