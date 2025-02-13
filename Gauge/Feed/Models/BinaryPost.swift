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
    var comments: [Comment]
    var responses: [Response]
    var category: Category
    var viewCounter: Int
    var responseCounter: Int
    var postDateAndTime: Date
    var favoritedBy: [String]
    
    var question: String
    var responseOption1: String
    var responseOption2: String
    var responseResult1: Int
    var responseResult2: Int
    
    init(postId: String, userId: String, comments: [Comment], responses: [Response], category: Category, viewCounter: Int, responseCounter: Int, postDateAndTime: Date, question: String, responseOption1: String, responseOption2: String, responseResult1: Int, responseResult2: Int, favoritedBy: [String]) {
        self.postId = postId
        self.userId = userId
        self.comments = comments
        self.responses = responses
        self.category = category
        self.viewCounter = viewCounter
        self.responseCounter = responseCounter
        self.postDateAndTime = postDateAndTime
        self.favoritedBy = favoritedBy
        
        self.question = question
        self.responseOption1 = responseOption1
        self.responseOption2 = responseOption2
        self.responseResult1 = responseResult1
        self.responseResult2 = responseResult2
    }
}
