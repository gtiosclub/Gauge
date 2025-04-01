//
//  UserResponses.swift
//  Gauge
//
//  Created by Kavya Adusumilli on 2/27/25.
//

import Foundation
import SwiftData
class UserResponses {
    var userCategoryResponses: [String : Int] // String is Category name .rawValue, Int is number of times interacted in session
    var userTopicResponses: [String : Int] // String is Topic name, Int is number of times interacted in session
    var currentUserCategories: [String] // Current category list (as rawValues) in Firebase
    var currentUserTopics: [String] // Current topic list in Firebase
    init(userCategoryResponses: [String : Int], userTopicResponses: [String : Int], currentUserCategories: [String], currentUserTopics: [String]) {
        self.userCategoryResponses = userCategoryResponses
        self.userTopicResponses = userTopicResponses
        self.currentUserCategories = currentUserCategories
        self.currentUserTopics = currentUserTopics
    }
    
}
    //container is where data is persisted.. create in separate file

