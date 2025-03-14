//
//  SliderPost.swift
//  Gauge
//
//  Created by Austin Huguenard on 2/2/25.
//

import Foundation

class SliderPost: Post, Equatable {
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
    
    // Slider post specific attributes
    var lowerBoundValue: Double
    var upperBoundValue: Double
    var lowerBoundLabel: String
    var upperBoundLabel: String
    
    // Initializing locally
    init (postId: String, userId: String, categories: [Category], postDateAndTime: Date, question: String, lowerBoundLabel: String, upperBoundLabel: String, lowerBoundValue: Double, upperBoundValue: Double) {
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
        
        // Slider post specific attributes
        self.lowerBoundLabel = lowerBoundLabel
        self.upperBoundLabel = upperBoundLabel
        self.lowerBoundValue = lowerBoundValue
        self.upperBoundValue = upperBoundValue
    }
    
    // Initializing from Firebase
    init(postId: String, userId: String, username: String = "", profilePhoto: String = "", comments: [Comment] = [], responses: [Response] = [], categories: [Category], viewCounter: Int = 0, postDateAndTime: Date, question: String, lowerBoundValue: Double, upperBoundValue: Double, lowerBoundLabel: String, upperBoundLabel: String, favoritedBy: [String]) {
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
        
        // Slider post specific attributes
        self.lowerBoundValue = lowerBoundValue
        self.upperBoundValue = upperBoundValue
        self.lowerBoundLabel = lowerBoundLabel
        self.upperBoundLabel = upperBoundLabel
    }
    
    static func == (lhs: SliderPost, rhs: SliderPost) -> Bool {
        return lhs.postId == rhs.postId
    }
}
