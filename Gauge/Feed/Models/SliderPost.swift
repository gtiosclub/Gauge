//
//  SliderPost.swift
//  Gauge
//
//  Created by Austin Huguenard on 2/2/25.
//

import Foundation

class SliderPost: Post {
    var postId: String
    var userId: String
    var comments: [String]
    var category: Category
    var viewCounter: Int
    var responseCounter: Int
    var postDateAndTime: Date
    
    var question: String
    var lowerBoundValue: Double
    var upperBoundValue: Double
    var lowerBoundLabel: String
    var upperBoundLabel: String
    var responseResults: [Double]
    
    init(postId: String, userId: String, comments: [String], category: Category, viewCounter: Int, responseCounter: Int, postDateAndTime: Date, question: String, lowerBoundValue: Double, upperBoundValue: Double, lowerBoundLabel: String, upperBoundLabel: String, responseResults: [Double]) {
        self.postId = postId
        self.userId = userId
        self.comments = comments
        self.category = category
        self.viewCounter = viewCounter
        self.responseCounter = responseCounter
        self.postDateAndTime = postDateAndTime
        self.question = question
        self.lowerBoundValue = lowerBoundValue
        self.upperBoundValue = upperBoundValue
        self.lowerBoundLabel = lowerBoundLabel
        self.upperBoundLabel = upperBoundLabel
        self.responseResults = responseResults
    }
}
