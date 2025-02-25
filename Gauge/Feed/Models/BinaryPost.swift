//
//  BinaryPost.swift
//  Gauge
//
//  Created by Austin Huguenard on 2/2/25.
//

import Foundation

class BinaryPost: Post, Equatable {
    // Post protocol attributes
    @Published var postId: String
    var userId: String
    var username: String = "" // NOT stored in Firebase
    var profilePhoto: String = "" // NOT stored in Firebase
    var comments: [Comment]
    var responses: [Response]
    var categories: [Category]
    var viewCounter: Int
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
    init(postId: String, userId: String, username: String = "", profilePhoto: String = "", comments: [Comment] = [], responses: [Response] = [], categories: [Category], viewCounter: Int = 0, postDateAndTime: Date, question: String, responseOption1: String, responseOption2: String, responseResult1: Int = 0, responseResult2: Int = 0, favoritedBy: [String]) {
        // Post protocol attributes
        self.postId = postId
        self.userId = userId
        self.username = username
        self.profilePhoto = profilePhoto
        self.comments = comments
        self.responses = responses
        self.categories = categories
        self.viewCounter = viewCounter
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
