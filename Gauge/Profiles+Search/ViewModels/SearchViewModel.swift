//
//  SearchViewModel.swift
//  Gauge
//
//  Created by Datta Kansal on 2/27/25.
//
import FirebaseFirestore
import Firebase
import Foundation

class SearchViewModel {
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
//        try await queryDocRef.delete()
        
        return postIds
    }
    
    func getPostQuestion(postId: String) async -> String? {
        do {
            let document = try await Firebase.db.collection("POSTS").document(postId).getDocument()
            guard let postData = document.data() else {return nil}
            guard let question = postData["question"] as? String else { return nil }
            return question
        } catch {
            return nil
        }
    }
    
    func getPostDateTime(postId: String) async -> Date? {
        do {
            let document = try await Firebase.db.collection("POSTS").document(postId).getDocument()
            guard let postData = document.data() else { return nil}
            guard let postDateAndTime = postData["postDateAndTime"] as? Timestamp else { return nil }
            return postDateAndTime.dateValue()
        } catch {
            return nil
        }
    }
    
    func getPostOptions(postId: String) async -> [String]? {
        do {
            let document = try await Firebase.db.collection("POSTS").document(postId).getDocument()
            guard let postData = document.data() else {return nil}
            guard let option1 = postData["responseOption1"] as? String else { return nil }
            guard let option2 = postData["responseOption2"] as? String else { return nil }
            return [option1, option2]
        } catch {
            return nil
        }
    }
}
