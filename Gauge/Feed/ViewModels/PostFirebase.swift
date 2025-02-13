//
//  PostFirebase.swift
//  Gauge
//
//  Created by Austin Huguenard on 2/6/25.
//

import Foundation
import Firebase

class PostFirebase: ObservableObject {
    @Published var feedPosts: [Post] = []
    @Published var allQueriedPosts: [Post] = []
    
    init() {
        Keys.fetchKeys()
    }
    
    func getLiveFeedPosts(user: User) {
        let allPosts: [String] = user.myViews + user.myResponses
        Firebase.db.collection("POSTS").whereField("postId", notIn: allPosts.isEmpty ? [""] : allPosts).addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot else {
                print("Error fetching post updates: \(error!)")
                return
            }
            
            for change in snapshot.documentChanges {
                if change.type == .added {
                    
                } else if change.type == .modified {

                } else if change.type == .removed {
                    
                }
            }
        }
    }
        
    func createBinaryPost(userId: String, category: Category, question: String, responseOption1: String, responseOption2: String) {
        // Create post instance
        let post = BinaryPost(
            postId: UUID().uuidString,
            userId: userId,
            category: category,
            postDateAndTime: Date(),
            question: question,
            responseOption1: responseOption1,
            responseOption2: responseOption2
        )
        
        // Create document in Firebase
        let documentRef = Firebase.db.collection("POSTS").document(post.postId)

        documentRef.setData([
            "type": PostType.BinaryPost.rawValue,
            "postId": post.postId,
            "userId": post.userId,
            "category": post.category.rawValue,
            "viewCounter": post.viewCounter,
            "responseCounter": post.responseCounter,
            "postDateAndTime": post.postDateAndTime,
            "question": post.question,
            "responseOption1": post.responseOption1,
            "responseOption2": post.responseOption2,
            "responseResult1": post.responseResult1,
            "responseResult2": post.responseResult2,
            "favoritedBy": post.favoritedBy
        ]) { error in
            if let error = error {
                print("error writing doc: \(error)")
            } else {
                print("added new post to POSTS")
            }
        }
    }
    
    func createSliderPost(userId: String, category: Category, question: String, lowerBoundValue: Double, upperBoundValue: Double, lowerBoundLabel: String, upperBoundLabel: String) {
        // Create post instance
        let post = SliderPost(
            postId: UUID().uuidString,
            userId: userId,
            category: category,
            postDateAndTime: Date(),
            question: question,
            lowerBoundLabel: lowerBoundLabel,
            upperBoundLabel: upperBoundLabel,
            lowerBoundValue: lowerBoundValue,
            upperBoundValue: upperBoundValue
        )
        
        // Create document in Firebase
        let documentRef = Firebase.db.collection("POSTS").document(post.postId)

        documentRef.setData([
            "type": PostType.SliderPost.rawValue,
            "postId": post.postId,
            "userId": post.userId,
            "category": post.category.rawValue,
            "viewCounter": post.viewCounter,
            "responseCounter": post.responseCounter,
            "postDateAndTime": post.postDateAndTime,
            "question": post.question,
            "lowerBoundValue": post.lowerBoundValue,
            "upperBoundValue": post.upperBoundValue,
            "lowerBoundLabel": post.lowerBoundLabel,
            "upperBoundLabel": post.upperBoundLabel,
            "responseResults": post.responseResults,
            "favoritedBy": post.favoritedBy
        ]) { error in
            if let error = error {
                print("error writing doc: \(error)")
            } else {
                print("added new post to POSTS")
            }
        }
    }
    
    func createRankPost(userId: String, category: Category, question: String, responseOptions: [String]) {
        let post = RankPost(
            postId: UUID().uuidString,
            userId: userId,
            category: category,
            postDateAndTime: Date(),
            question: question,
            responseOptions: responseOptions
        )
        
        let documentRef = Firebase.db.collection("POSTS").document(post.postId)
        
        // Main post document data
        documentRef.setData([
            "type": PostType.RankPost.rawValue,
            "postId": post.postId,
            "userId": post.userId,
            "category": post.category.rawValue,
            "postDateAndTime": Timestamp(date: post.postDateAndTime),
            "question": post.question,
            "responseOptions": post.responseOptions,
            "viewCounter": 0,
            "responseCounter": 0,
            "favoritedBy": post.favoritedBy,
            "responseResults": post.responseResults
        ]) { error in
            if let error = error {
                print("Error writing RankPost document: \(error)")
            } else {
                print("Added new ranked post to POSTS \(documentRef.documentID)")
            }
        }
    }
    
    
    func addComment(postId: String, commentId: String, commentType: CommentType, userId: String ,content: String){
            let newCommentRef = Firebase.db.collection("POSTS")
                .document(postId).collection("COMMENTS").document(commentId)
            
            newCommentRef.setData([
                "postId" : postId,
                "commentId" : commentId,
                "commentType": String(describing: commentType),
                "userId": userId ,
                "content": content,
                "likes" : [],
                "dislikes" : [],
            ]) { error in
                if let error = error{
                    print("Error adding Comment: \(error)")
                } else {
                    print("added new comment to COMMENTS")
                }
            }
        }
    func deleteComment(postId: String, commentId: String){
        Firebase.db.collection("POSTS").document(postId).collection("COMMENTS").document(commentId).delete(){ error in
            if let error = error{
                print("Error deleting Comment: \(error)")
            } else {
                print("deleted comment from COMMENTS")
            }
        }
    }



}
