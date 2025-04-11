//
//  SearchViewModel.swift
//  Gauge
//
//  Created by Datta Kansal on 2/27/25.
//
import FirebaseFirestore
import Firebase
import Foundation
<<<<<<< HEAD
import SwiftUICore
=======
import UIKit
>>>>>>> main

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
        
        let request: [String: Any] = [ "query": query ]
        try await queryDocRef.setData(request)
        
        var postIds: [String] = []
        var attempts = 0
        let maxAttempts = 10
        
        while attempts < maxAttempts {
            attempts += 1
            try await Task.sleep(nanoseconds: 500_000_000) // 500ms
            let docSnapshot = try await queryDocRef.getDocument()
            guard let data = docSnapshot.data() else {
                print("No data on attempt \(attempts)")
                continue
            }
            
            print("Attempt \(attempts) - status data: \(data["status"] ?? "nil")")
            if let status = data["status"] as? [String: Any],
               let textQuery = status["textQuery"] as? [String: Any],
               let state = textQuery["state"] as? String,
               state == "COMPLETED" {
                
                if let result = data["result"] as? [String: Any],
                   let ids = result["ids"] as? [String] {
                    postIds = ids
                    print("Vector search COMPLETED with \(ids.count) ids.")
                } else {
                    print("No IDs found in result.")
                }
                break
            }
        }
        try await queryDocRef.delete()
        print("Returning \(postIds.count) post IDs for query: \(query)")
        return postIds
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
    
    
    func getPostDetails(for postId: String) async -> PostResult? {
        do {
            let doc = try await Firebase.db.collection("POSTS").document(postId).getDocument()
            guard let data = doc.data() else {
                print("No data for postId: \(postId)")
                return nil
            }
            
            guard let question = data["question"] as? String,
                  let dateString = data["postDateAndTime"] as? String,
                  let date = DateConverter.convertStringToDate(dateString)
            else {
                print("Missing required fields (question or postDateAndTime) for postId: \(postId)")
                return nil
            }
            
            let profilePhoto = data["profilePhoto"] as? String ?? ""
            let username = data["username"] as? String ?? "Unknown"
            let categories = data["categories"] as? [String] ?? []
            
            let responsesSnapshot = try await Firebase.db.collection("POSTS").document(postId).collection("RESPONSES").getDocuments()
            let voteCount = responsesSnapshot.documents.count
            let timeAgo = DateConverter.timeAgo(from: date)
            
            return PostResult(id: postId,
                              question: question,
                              timeAgo: timeAgo,
                              username: username,
                              profilePhoto: profilePhoto,
                              categories: categories,
                              voteCount: voteCount)
        } catch {
            print("Error fetching full post details for \(postId): \(error.localizedDescription)")
            return nil
        }
    }
    
    func searchPosts(for query: String) async throws -> [PostResult] {
        let postIds = try await searchSimilarQuestions(query: query)
        print("Vector search returned \(postIds.count) post IDs for query: \(query)")
        var results: [PostResult] = []
        
        for postId in postIds {
            if let details = await getPostDetails(for: postId) {
                results.append(details)
            } else {
                print("No details for postId: \(postId)")
            }
        }
        
        print("Topic search returning \(results.count) posts for query: \(query)")
        return results
    }
    
    
    func searchPostsByCategory(_ category: Category) async throws -> [PostResult] {
        print("Filtering posts for category: \(category.rawValue)")
        let snapshot = try await Firestore.firestore()
            .collection("POSTS")
            .whereField("categories", arrayContains: category.rawValue)
            .getDocuments()
        
        print("Category query for \(category.rawValue) returned \(snapshot.documents.count) documents.")
        
        var results: [PostResult] = []
        for document in snapshot.documents {
            let postId = document.documentID
            if let details = await getPostDetails(for: postId) {
                results.append(details)
            } else {
                print("Failed to get details for postId: \(postId) in category search.")
            }
        }
        
        print("Category search returning \(results.count) posts for category: \(category.rawValue)")
        return results
    }

    func fetchUsers(for query: String) async throws -> [UserResult] {
        let snapshot = try await Firebase.db.collection("USERS")
            .whereField("username", isGreaterThanOrEqualTo: query.lowercased())
            .whereField("username", isLessThan: query.lowercased() + "\u{f8ff}")
            .limit(to: 10)
            .getDocuments()

        return try snapshot.documents.compactMap { document -> UserResult? in
            let data = document.data()
            
            var result = UserResult(
                userId: document.documentID,
                username: data["username"] as? String ?? "",
                profilePhotoUrl: data["profilePhoto"] as? String ?? ""
            )
            
            result.attributes = data["attributes"] as? [String: String] ?? [:]
            
            return result
        }
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
