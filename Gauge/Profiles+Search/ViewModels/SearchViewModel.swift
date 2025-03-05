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
}
