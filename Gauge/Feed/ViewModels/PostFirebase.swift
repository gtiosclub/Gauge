//
//  PostFirebase.swift
//  Gauge
//
//  Created by Austin Huguenard on 2/6/25.
//

import Foundation

class PostFirebase {
    
    func createBinaryPost(userId: String, category: Category, question: String, responseOption1: String, responseOption2: String) {
        
        let documentRef = Firebase.db.collection("users").addDocument(data: [:])

        documentRef.setData([
            "type": PostType.BinaryPost.rawValue,
            "postId": UUID().uuidString,
            "userId": userId,
            "category": category.rawValue,
            "viewCounter": 0,
            "responseCounter": 0,
            "postDateAndTime": Date(),
            "question": question,
            "responseOption1": responseOption1,
            "responseOption2": responseOption2,
            "responseResult1": 0,
            "responseResult2": 0
        ]) { error in
            if let error = error {
                print("error writing doc: \(error)")
            } else {
                print("added new post to POSTS")
                documentRef.collection("COMMENTS")
                documentRef.collection("RESPONSES")
                
            }
        }
    }
    
}
