//
//  BinaryPost.swift
//  Gauge
//
//  Created by Austin Huguenard on 2/2/25.
//

import Foundation

class BinaryPost: Post, Equatable {    
    // Post protocol attributes
    var postId: String
    var userId: String
    var comments: [Comment]
    var responses: [Response]
    var categories: [Category]
    var viewCounter: Int
    var responseCounter: Int
    var postDateAndTime: Date
    var favoritedBy: [String]
    var question: String
    
    // Binary post specific attributes
    var responseOption1: String
    var responseOption2: String
    var responseResult1: Int
    var responseResult2: Int
    
    // Initializing locally
    init (postId: String, userId: String, categories: [Category], postDateAndTime: Date, question: String, responseOption1: String, responseOption2: String) {
        // Post protocol attributes
        self.postId = postId
        self.userId = userId
        self.comments = []
        self.responses = []
        self.categories = categories
        self.viewCounter = 0
        self.responseCounter = 0
        self.postDateAndTime = postDateAndTime
        self.favoritedBy = []
        self.question = question
        
        // Binary post specific attributes
        self.responseOption1 = responseOption1
        self.responseOption2 = responseOption2
        self.responseResult1 = 0
        self.responseResult2 = 0
    }
    
    // Initializing from Firebase
    init(postId: String, userId: String, comments: [Comment], responses: [Response], categories: [Category], viewCounter: Int, responseCounter: Int, postDateAndTime: Date, question: String, responseOption1: String, responseOption2: String, responseResult1: Int, responseResult2: Int, favoritedBy: [String]) {
        // Post protocol attributes
        self.postId = postId
        self.userId = userId
        self.comments = comments
        self.responses = responses
        self.categories = categories
        self.viewCounter = viewCounter
        self.responseCounter = responseCounter
        self.postDateAndTime = postDateAndTime
        self.favoritedBy = favoritedBy
        self.question = question
        
        // Binary post specific attributes
        self.responseOption1 = responseOption1
        self.responseOption2 = responseOption2
        self.responseResult1 = responseResult1
        self.responseResult2 = responseResult2
    }
    static func == (lhs: BinaryPost, rhs: BinaryPost) -> Bool {
        return lhs.postId == rhs.postId
    }
}
