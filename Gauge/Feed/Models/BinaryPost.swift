//
//  BinaryPost.swift
//  Gauge
//
//  Created by Austin Huguenard on 2/2/25.
//

import Foundation

class BinaryPost: Post {
    var postId: String
    var userId: String
    var comments: [String]
    var category: Category
    var viewCounter: Int
    var responseCounter: Int
    var postDateAndTime: Date
    
    var question: String
    var responseOptions: [String] // Length 2
    var responseResults: [Int] // Length 2
    
    init(postId: String, userId: String, comments: [String], category: Category, viewCounter: Int, responseCounter: Int, postDateAndTime: Date, question: String, responseOptions: [String], responseResults: [Int]) {
        self.postId = postId
        self.userId = userId
        self.comments = comments
        self.category = category
        self.viewCounter = viewCounter
        self.responseCounter = responseCounter
        self.postDateAndTime = postDateAndTime
        self.question = question
        self.responseOptions = responseOptions
        self.responseResults = responseResults
    }
}
