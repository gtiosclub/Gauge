//
//  UserResponses.swift
//  Gauge
//
//  Created by Kavya Adusumilli on 2/27/25.
//

import Foundation
import SwiftData

@Model
class UserResponses {
    var userCategoryResponses: [String : Int] // String is Category name .rawValue, Int is number of times interacted in session
    var userTopicResponses: [String : Int] // String is Topic name, Int is number of times interacted in session
    var currentUserCategories: [String] // Current category list (as rawValues) in Firebase
    var currentUserTopics: [String] // Current topic list in Firebase
    @Attribute(.unique) var id: UUID
    
    init(userCategoryResponses: [String : Int] = [:], userTopicResponses: [String : Int] = [:], currentUserCategories: [String] = [], currentUserTopics: [String] = []) {
        self.userCategoryResponses = userCategoryResponses
        self.userTopicResponses = userTopicResponses
        self.currentUserCategories = currentUserCategories
        self.currentUserTopics = currentUserTopics
        self.id = UUID()
    }
    
    func addToUserTopics(topics: [String]) {
        for topic in topics {
            if let currentCount = userTopicResponses[topic] {
                userTopicResponses[topic] = currentCount + 1
            } else {
                userTopicResponses[topic] = 1
            }
        }
    }
    
    func addToUserCategories(categories: [String]) {
        for category in categories {
            if currentUserCategories.contains(category) {
                if let currentCount = userCategoryResponses[category] {
                    userCategoryResponses[category] = currentCount + 1
                } else {
                    userCategoryResponses[category] = 1
                }
            }
        }
    }
    
    func removeFromUserTopics(topics: [String]) {
        for topic in topics {
            if let currentCount = userTopicResponses[topic] {
                userTopicResponses[topic] = currentCount - 1
            } else {
                userTopicResponses[topic] = -1
            }
        }
    }
    
    func removeFromUserCategories(categories: [String]) {
        for category in categories {
            if currentUserCategories.contains(category) {
                if let currentCount = userCategoryResponses[category] {
                    userCategoryResponses[category] = currentCount - 1
                } else {
                    userCategoryResponses[category] = -1
                }
            }
        }
    }
}
