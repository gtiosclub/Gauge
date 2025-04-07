//
//  SearchViewModel.swift
//  Gauge
//
//  Created by Datta Kansal on 2/27/25.
//
import FirebaseFirestore
import Firebase
import Foundation

class SearchViewModel: ObservableObject {
    @Published var recentSearchesUpdated = false // trigger state updates in the search bar (recent searches)
    @Published var user: User // assuming UserModel is your user type
    
    init(user: User) {
        self.user = user
    }
    private let vectorSearchCollection = "_firestore-vector-search"
    
    func searchSimilarQuestions(query: String) async throws -> [String] {
        let queryDocRef = Firebase.db.collection(vectorSearchCollection)
            .document("index")
            .collection("queries")
            .document()
        
        let request: [String: Any] = [
            "query": query
        ]
        
        try await queryDocRef.setData(request)
        
        var postIds: [String] = []
        var attempts = 0
        let maxAttempts = 10
        
        while attempts < maxAttempts {
            attempts += 1
            
            try await Task.sleep(nanoseconds: 500_000_000) // 500ms
            
            let docSnapshot = try await queryDocRef.getDocument()
            guard let data = docSnapshot.data() else { continue }
            
            if let status = data["status"] as? [String: Any],
               let textQuery = status["textQuery"] as? [String: Any],
               let state = textQuery["state"] as? String,
               state == "COMPLETED" {
                
                if let result = data["result"] as? [String: Any],
                   let ids = result["ids"] as? [String] {
                    postIds = ids
                }
                break
            }
        }
        try await queryDocRef.delete()
        
        return postIds
    }
    
    func getPostQuestion(postId: String) async -> String? {
        do {
            let document = try await Firebase.db.collection("POSTS").document(postId).getDocument()
            guard let postData = document.data() else { return nil }
            return postData["question"] as? String
        } catch {
            return nil
        }
    }
    
    func getPostDateTime(postId: String) async -> String? {
        do {
            let document = try await Firebase.db.collection("POSTS").document(postId).getDocument()
            guard let postData = document.data() else { return nil }
            guard let postDateAndTime = postData["postDateAndTime"] as? String else { return nil }
            return DateConverter.timeAgo(from: DateConverter.convertStringToDate(postDateAndTime) ?? Date())
        } catch {
            return nil
        }
    }
    
    func getPostOptions(postId: String) async -> [String]? {
        do {
            let document = try await Firebase.db.collection("POSTS").document(postId).getDocument()
            guard let postData = document.data() else { return nil }
            guard let option1 = postData["responseOption1"] as? String else { return nil }
            guard let option2 = postData["responseOption2"] as? String else { return nil }
            return [option1, option2]
        } catch {
            return nil
        }
    }
    
    /// Combines the three awaits into one function that returns a PostResult.
    func getPostDetails(for postId: String) async -> PostResult? {
        async let question = getPostQuestion(postId: postId)
        async let options = getPostOptions(postId: postId)
        async let timeAgo = getPostDateTime(postId: postId)
        
        let (q, opts, ta) = await (question, options, timeAgo)
        guard let q = q else { return nil }
        return PostResult(id: postId, question: q, options: opts ?? [], timeAgo: ta ?? "Just now")
    }
    
    func searchPosts(for query: String) async throws -> [PostResult] {
        let postIds = try await searchSimilarQuestions(query: query)
        var results: [PostResult] = []
        
        for postId in postIds {
            if let details = await getPostDetails(for: postId) {
                results.append(details)
            }
        }
        
        return results
    }
    
    func searchQuestions(for query: String) async throws -> [String] {
        let postIds = try await searchSimilarQuestions(query: query)
        var questions: [String] = []
        
        for postId in postIds {
            if let question = await getPostQuestion(postId: postId) {
                questions.append(question)
            }
        }
        
        return questions
    }
    
    func addRecentlySearchedPost(search: String) {
        // local model update
        if user.myPostSearches.contains(search) {
            user.myPostSearches.removeAll(where: { $0 == search })
        }
        user.myPostSearches.append(search)

        // Firestore update
        let userRef = Firebase.db.collection("USERS").document(user.userId)

        userRef.getDocument { document, error in
            guard let document = document, document.exists,
                  var existingSearches = document.get("myPostSearches") as? [String] else {
                return
            }

            // Remove search if it exists
            if existingSearches.contains(search) {
                userRef.updateData([
                    "myPostSearches": FieldValue.arrayRemove([search])
                ]) { _ in
                    // Re-add after removal to move it to the end
                    userRef.updateData([
                        "myPostSearches": FieldValue.arrayUnion([search])
                    ])
                }
            } else {
                // add search it doesn't exist
                userRef.updateData([
                    "myPostSearches": FieldValue.arrayUnion([search])
                ])
            }
        }
    }
    
    func addRecentlySearchedProfile(search: String) {
        // local model update
        if user.myProfileSearches.contains(search) {
            user.myProfileSearches.removeAll(where: { $0 == search })
        }
        user.myProfileSearches.append(search)

        // Firestore update
        let userRef = Firebase.db.collection("USERS").document(user.userId)

        userRef.getDocument { document, error in
            guard let document = document, document.exists,
                  var existingSearches = document.get("myProfileSearches") as? [String] else {
                return
            }

            // Remove search if it exists
            if existingSearches.contains(search) {
                userRef.updateData([
                    "myProfileSearches": FieldValue.arrayRemove([search])
                ]) { _ in
                    // Re-add after removal to move it to the end
                    userRef.updateData([
                        "myProfileSearches": FieldValue.arrayUnion([search])
                    ])
                }
            } else {
                // add search it doesn't exist
                userRef.updateData([
                    "myProfileSearches": FieldValue.arrayUnion([search])
                ])
            }
        }
    }
    
    //delete recent searches
   func deleteRecentlySearched(_ search: String, isProfileSearch: Bool) {
       let key = isProfileSearch ? "myProfileSearches" : "myPostSearches"

       // Remove locally
       if isProfileSearch {
           if let index = user.myProfileSearches.firstIndex(of: search) {
               user.myProfileSearches.remove(at: index)
           }
       } else {
           if let index = user.myPostSearches.firstIndex(of: search) {
               user.myPostSearches.remove(at: index)
           }
       }
       //retrigger render in view
       recentSearchesUpdated.toggle()

       // Remove in Firebase
       let userRef = Firebase.db.collection("USERS").document(user.userId)
       userRef.updateData([
           key: FieldValue.arrayRemove([search])
       ])
   }
    
}
