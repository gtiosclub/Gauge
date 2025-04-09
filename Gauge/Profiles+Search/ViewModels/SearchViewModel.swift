//
//  SearchViewModel.swift
//  Gauge
//
//  Created by Datta Kansal on 2/27/25.
//
import FirebaseFirestore
import Firebase
import Foundation
import SwiftUICore

@MainActor
class SearchViewModel: ObservableObject {
    @Published var recentSearchesUpdated = false // trigger state updates in the search bar (recent searches)
    private let vectorSearchCollection = "_firestore-vector-search"
    // updates the last 5 in functions - to easily display in ProfileView
    @Published var recentFiveTopics : [String] = []
    @Published var recentFiveProfiles : [String] = []
    
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
    
    
    
    
    
    
    
    
    
    
    func addRecentlySearchedPost(userId: String, search: String) {
        let userRef = Firebase.db.collection("USERS").document(userId)

        userRef.getDocument { document, error in
            guard let document = document, document.exists,
                  var existingSearches = document.get("myPostSearches") as? [String] else {
                return
            }

            // Update Firestore
            if existingSearches.contains(search) {
                userRef.updateData([
                    "myPostSearches": FieldValue.arrayRemove([search])
                ]) { _ in
                    userRef.updateData([
                        "myPostSearches": FieldValue.arrayUnion([search])
                    ])
                }
            } else {
                userRef.updateData([
                    "myPostSearches": FieldValue.arrayUnion([search])
                ])
            }

            // Update local state: remove then append to ensure it's most recent
            DispatchQueue.main.async {
                self.recentFiveTopics.removeAll(where: { $0 == search })
                self.recentFiveTopics.append(search)

                // Keep only the last 5
                if self.recentFiveTopics.count > 5 {
                    self.recentFiveTopics = Array(self.recentFiveTopics.suffix(5))
                }
            }
        }
    }

    
    func addRecentlySearchedProfile(userId: String, search: String) {
        let userRef = Firebase.db.collection("USERS").document(userId)

        userRef.getDocument { document, error in
            guard let document = document, document.exists,
                  var existingSearches = document.get("myProfileSearches") as? [String] else {
                return
            }

            // Update Firestore
            if existingSearches.contains(search) {
                userRef.updateData([
                    "myProfileSearches": FieldValue.arrayRemove([search])
                ]) { _ in
                    userRef.updateData([
                        "myProfileSearches": FieldValue.arrayUnion([search])
                    ])
                }
            } else {
                userRef.updateData([
                    "myProfileSearches": FieldValue.arrayUnion([search])
                ])
            }

            // Update local state for UI
            DispatchQueue.main.async {
                self.recentFiveProfiles.removeAll(where: { $0 == search })
                self.recentFiveProfiles.append(search)

                if self.recentFiveProfiles.count > 5 {
                    self.recentFiveProfiles = Array(self.recentFiveProfiles.suffix(5))
                }
            }
        }
    }
    
    func deleteRecentlySearched(userId: String, searchTerm: String, isProfileSearch: Bool) {
        let key = isProfileSearch ? "myProfileSearches" : "myPostSearches"
        let userRef = Firebase.db.collection("USERS").document(userId)
        
        // Remove from Firestore
        userRef.updateData([
            key: FieldValue.arrayRemove([searchTerm])
        ])
        
        // Update local array
        DispatchQueue.main.async {
            if isProfileSearch {
                self.recentFiveProfiles.removeAll { $0 == searchTerm }
            } else {
                self.recentFiveTopics.removeAll { $0 == searchTerm }
            }
        }
    }
    // get last 5 searches
    func lastFiveSearches(userID: String, isProfileSearch: Bool) async -> [String] {
        let key = isProfileSearch ? "myProfileSearches" : "myPostSearches"
        let userDocument = Firebase.db.collection("USERS").document(userID)

        do {
            let document = try await userDocument.getDocument()
            guard let userData = document.data() else { return [] }

            let allSearches = userData[key] as? [String] ?? []
            let lastFive = allSearches.suffix(5)

            // update local array holding last 5 searches
            if isProfileSearch {
                self.recentFiveProfiles = Array(lastFive)
            } else {
                self.recentFiveTopics = Array(lastFive)
            }

            return Array(lastFive)
        } catch {
            print("Error fetching document: \(error.localizedDescription)")
            return []
        }
    }



    
}
