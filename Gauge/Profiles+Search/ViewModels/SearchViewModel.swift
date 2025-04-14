//
//  SearchViewModel.swift
//  Gauge
//
//  Created by Datta Kansal on 2/27/25.
//
import FirebaseFirestore
import Firebase
import Foundation
import UIKit

class SearchViewModel: ObservableObject {
    private let vectorSearchCollection = "_firestore-vector-search"
    
    func searchSimilarQuestions(query: String) async throws -> [String] {
        let queryDocRef = Firebase.db.collection(vectorSearchCollection)
            .document("index")
            .collection("queries")
            .document()
        
        let request: [String: Any] = [ "query": query ]
        try await queryDocRef.setData(request)
        
        var postIds: [String] = []
        var attempts = 0
        let maxAttempts = 15
        
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
            let userId = data["userId"] as? String ?? ""
            
            let responsesSnapshot = try await Firebase.db.collection("POSTS").document(postId).collection("RESPONSES").getDocuments()
            let voteCount = responsesSnapshot.documents.count
            let timeAgo = DateConverter.timeAgo(from: date)
            
            return PostResult(id: postId,
                              userId: userId,
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
    
    func getFriendInteractors(for postId: String, myFriends: [String]) async throws -> [String] {
        let responsesSnapshot = try await Firebase.db.collection("POSTS").document(postId).collection("RESPONSES").getDocuments()
        
        let responseUserIds = responsesSnapshot.documents.compactMap { $0.data()["userId"] as? String }
    
        let friendResponses = responseUserIds.filter { myFriends.contains($0) }
        
        let uniqueFriendIds = Array(Set(friendResponses)).prefix(2)
        let friendCount = uniqueFriendIds.count
//        print("SearchViewModel.getFriendInteractors: found \(friendCount) friend interactors for post \(postId).")
        return Array(uniqueFriendIds)
    }
}
