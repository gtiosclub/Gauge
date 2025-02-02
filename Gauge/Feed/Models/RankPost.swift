//
//  RankPost.swift
//  Gauge
//
//  Created by Austin Huguenard on 2/2/25.
//

import Foundation

class RankPost: Post {
    var postId: String
    var userId: String
    var comments: [String]
    var category: Category
    var viewCounter: Int
    var responseCounter: Int
    var postDateAndTime: Date
    
    var question: String
    var responseOptions: [String]
    var responseResults: [[String]]
    
    init(postId: String, userId: String, comments: [String], category: Category, viewCounter: Int, responseCounter: Int, postDateAndTime: Date, question: String, responseOptions: [String], responseResults: [[String]]) {
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
