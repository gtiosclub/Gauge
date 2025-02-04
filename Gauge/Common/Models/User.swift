//
//  User.swift
//  Gauge
//
//  Created by Austin Huguenard on 2/2/25.
//

import Foundation

class User: Equatable, Identifiable {
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id && lhs.username == rhs.username && lhs.phoneNumber == rhs.phoneNumber
    }
    
    // MANDATORY
    var id: String { userId }
    var userId: String
    var username: String
    var phoneNumber: String
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
    
    init(userId: String, username: String, phoneNumber: String) {
        self.userId = userId
        self.username = username
        self.phoneNumber = phoneNumber
    }
    
    init(userId: String, username: String, phoneNumber: String, friendIn: [User], friendOut: [User], friends: [User], myPosts: [String], myResponses: [String], myReactions: [String], mySearches: [String], myComments: [String], myCategories: [String], badges: [String]) {
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
