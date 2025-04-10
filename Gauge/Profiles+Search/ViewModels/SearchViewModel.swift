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
    
    func searchPostsByCategory(_ category: Category) async throws -> [PostResult] {

        let snapshot = try await Firestore.firestore()
            .collection("POSTS")
            .whereField("categories", arrayContains: category.rawValue)
            .getDocuments()


        var results: [PostResult] = []

        for document in snapshot.documents {
            let data = document.data()

            guard let question = data["question"] as? String else { continue }
            let options = [
                data["responseOption1"] as? String ?? "",
                data["responseOption2"] as? String ?? ""
            ]
            let postId = document.documentID
            let postDateAndTime = data["postDateAndTime"] as? String ?? ""
            let timeAgo = DateConverter.timeAgo(from: DateConverter.convertStringToDate(postDateAndTime) ?? Date())

            let postResult = PostResult(id: postId, question: question, options: options, timeAgo: timeAgo)
            results.append(postResult)
        }

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
}
