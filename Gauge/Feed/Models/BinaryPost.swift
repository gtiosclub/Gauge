//
//  BinaryPost.swift
//  Gauge
//
//  Created by Austin Huguenard on 2/2/25.
//

import Foundation

class BinaryPost: Post, Equatable, ObservableObject {
    // Post protocol attributes
    @Published var postId: String
    var userId: String
    var username: String = "" // NOT stored in Firebase
    var profilePhoto: String = "" // NOT stored in Firebase
    @Published var categories: [Category]
    var topics: [String]
    var postDateAndTime: Date
    var favoritedBy: [String]
    var question: String
    
    // From subcollection
    @Published var responses: [Response]
    @Published var viewCounter: Int
    @Published var comments: [Comment]
    
    // Binary post specific attributes
    var responseOption1: String
    var responseOption2: String
    
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
        self.topics = []
        
        // Binary post specific attributes
        self.responseOption1 = responseOption1
        self.responseOption2 = responseOption2
    }
    
    // Initializing from Firebase
    init(postId: String, userId: String, username: String = "", profilePhoto: String = "", comments: [Comment] = [], responses: [Response] = [], categories: [Category], topics: [String], viewCounter: Int = 0, postDateAndTime: Date, question: String, responseOption1: String, responseOption2: String, favoritedBy: [String]) {
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
        self.topics = topics
        
        // Binary post specific attributes
        self.responseOption1 = responseOption1
        self.responseOption2 = responseOption2
    }
    
    static func == (lhs: BinaryPost, rhs: BinaryPost) -> Bool {
        return lhs.postId == rhs.postId
    }
    
    func calculateResponses() -> [Int] {
        var responses = [0, 0]
        for response in self.responses {
            if response.responseOption == self.responseOption1 {
                responses[0] += 1
            } else {
                responses[1] += 1
            }
        }
        
        return responses
    }
}
