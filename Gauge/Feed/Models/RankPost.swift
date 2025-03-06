//
//  RankPost.swift
//  Gauge
//
//  Created by Austin Huguenard on 2/2/25.
//

import Foundation

class RankPost: Post, Equatable {
    // Post protocol attributes
    @Published var postId: String
    var userId: String
    var username: String = "" // NOT stored in Firebase
    var profilePhoto: String = "" // NOT stored in Firebase
    var comments: [Comment]
    var responses: [Response]
    var category: Category
    var viewCounter: Int
    var postDateAndTime: Date
    
    var question: String
    var responseOptions: [String]
    
    // Initializing locally
    init (postId: String, userId: String, categories: [Category], postDateAndTime: Date, question: String, responseOptions: [String]) {
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
        
        // Rank post specific attributes
        self.responseOptions = responseOptions
    }
    
    // Initializing from Firebase
    init(postId: String, userId: String, username: String = "", profilePhoto: String = "", comments: [Comment] = [], responses: [Response] = [], categories: [Category], viewCounter: Int = 0, postDateAndTime: Date, question: String, responseOptions: [String], favoritedBy: [String]) {
        // Post protocol attributes
        self.postId = postId
        self.userId = userId
        self.username = username
        self.profilePhoto = profilePhoto
        self.comments = comments
        self.responses = responses
        self.category = category
        self.viewCounter = viewCounter
        self.postDateAndTime = postDateAndTime
        self.question = question
        self.responseOptions = responseOptions
    }
    
    static func == (lhs: RankPost, rhs: RankPost) -> Bool {
        return lhs.postId == rhs.postId
    }
}
