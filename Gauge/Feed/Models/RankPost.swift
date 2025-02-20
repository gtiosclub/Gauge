//
//  RankPost.swift
//  Gauge
//
//  Created by Austin Huguenard on 2/2/25.
//

import Foundation

class RankPost: Post {
    // Post protocol attributes
    var postId: String
    var userId: String
    var username: String = "" // NOT stored in Firebase
    var profilePhoto: String = "" // NOT stored in Firebase
    var comments: [Comment]
    var responses: [Response]
    var categories: [Category]
    var viewCounter: Int
    var responseCounter: Int
    var postDateAndTime: Date
    var favoritedBy: [String]
    var question: String
    
    // Rank post specific attributes
    var responseOptions: [String]
    var responseResults: [String : Int]
    
    // Initializing locally
    init (postId: String, userId: String, categories: [Category], postDateAndTime: Date, question: String, responseOptions: [String]) {
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
        
        // Rank post specific attributes
        self.responseOptions = responseOptions
        self.responseResults = [:]
    }
    
    // Initializing from Firebase
    init(postId: String, userId: String, username: String, profilePhoto: String, comments: [Comment], responses: [Response], categories: [Category], viewCounter: Int, responseCounter: Int, postDateAndTime: Date, question: String, responseOptions: [String], responseResults: [String : Int], favoritedBy: [String]) {
        // Post protocol attributes
        self.postId = postId
        self.userId = userId
        self.username = username
        self.profilePhoto = profilePhoto
        self.comments = comments
        self.responses = responses
        self.categories = categories
        self.viewCounter = viewCounter
        self.responseCounter = responseCounter
        self.postDateAndTime = postDateAndTime
        self.favoritedBy = favoritedBy
        self.question = question
        
        // Rank post specific attributes
        self.responseOptions = responseOptions
        self.responseResults = responseResults
    }
}
