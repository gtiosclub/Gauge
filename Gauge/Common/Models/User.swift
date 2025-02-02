//
//  User.swift
//  Gauge
//
//  Created by Austin Huguenard on 2/2/25.
//

import Foundation

class User {
    // MANDATORY
    var userId: String
    var username: String
    var phoneNumber: Int
    // MANDATORY
    
    var friendIn: [User] = []
    var friendOut: [User] = []
    var friends: [User] = []
    var myPosts: [String] = []
    var myResponses: [String] = []
    var myReactions: [String] = []
    var mySearches: [String] = []
    var myComments: [String] = []
    var myCategories: [String] = []
    var badges: [String] = []
    
    init(userId: String, username: String, phoneNumber: Int) {
        self.userId = userId
        self.username = username
        self.phoneNumber = phoneNumber
    }
    
    init(userId: String, username: String, phoneNumber: Int, friendIn: [User], friendOut: [User], friends: [User], myPosts: [String], myResponses: [String], myReactions: [String], mySearches: [String], myComments: [String], myCategories: [String], badges: [String]) {
        self.userId = userId
        self.username = username
        self.phoneNumber = phoneNumber
        self.friendIn = friendIn
        self.friendOut = friendOut
        self.friends = friends
        self.myPosts = myPosts
        self.myResponses = myResponses
        self.myReactions = myReactions
        self.mySearches = mySearches
        self.myComments = myComments
        self.myCategories = myCategories
        self.badges = badges
    }
}
