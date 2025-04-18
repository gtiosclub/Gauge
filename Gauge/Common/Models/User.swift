//
//  User.swift
//  Gauge
//
//  Created by Austin Huguenard on 2/2/25.
//

import Foundation

class User: Equatable, Identifiable, ObservableObject {
    // MARK: MANDATORY
    var id: String { userId } // Derived attribute from userId to conform to Equatable, does NOT need to be in init
    @Published var userId: String
    @Published var username: String
    var email: String
    var lastLogin: Date
    var lastFeedRefresh: Date
    var streak: Int
    var attributes: [String: String] = [:]
    // MARK: MANDATORY
    
    var friendIn: [String] = [] // userIds
    var friendOut: [String] = [] // userIds
    var friends: [String] = [] // userIds
    var badges: [String] = []
    var profilePhoto: String
    var phoneNumber: String = ""
    var myCategories: [String] = []
    var myTopics: [String] = [] // List of topics that user is interested in / interact with
    var myNextPosts: [String] = []
    var myTakeTime: [String:Int] = [:]

    // MARK: AI Algorithm Variables
    @Published var myPosts: [String] = [] // PostIds of the user's posts
    @Published var myResponses: [String] = [] // PostIds of those responded to
    @Published var myViews: [String] = [] // PostIds of those skipped
    @Published var myFavorites: [String] = [] // PostIds of those favorited
    @Published var myComments: [String] = [] // PostIds of those commented on
    var myPostSearches: [String] = [] // Search queries
    var myProfileSearches: [String] = [] //search queries
    var myAccessedProfiles: [String] // UserIDs of other users, sorted by profile accesses
    // MARK: AI Algorithm Variables
    
    // MARK: STATS
    var numUserResponses: Int = 0
    var numUserViews: Int = 0
    // MARK: STATS
    
    init(userId: String, username: String, email: String) {
        self.userId = userId
        self.username = username
        self.email = email
        self.lastLogin = Date()
        self.lastFeedRefresh = Date()
        self.streak = 0
        self.myAccessedProfiles = []
        self.profilePhoto = ""
        self.attributes = [:]
    }


    init(userId: String, username: String, phoneNumber: String, email: String, friendIn: [String], friendOut: [String], friends: [String], myNextPosts: [String], myResponses: [String] = [], myFavorites: [String] = [], myPostSearches: [String], myProfileSearches:[String], myComments: [String] = [], myCategories: [String], myTopics: [String], badges: [String], streak: Int, profilePhoto: String, myAccessedProfiles: [String], lastLogin: Date, lastFeedRefresh: Date, attributes: [String: String], myTakeTime: [String:Int]) {
        self.userId = userId
        self.username = username
        self.phoneNumber = phoneNumber
        self.email = email
        self.friendIn = friendIn
        self.friendOut = friendOut
        self.friends = friends
        self.myNextPosts = myNextPosts
        self.myResponses = myResponses
        self.myFavorites = myFavorites
        self.myPostSearches = myPostSearches
        self.myProfileSearches = myProfileSearches
        self.myComments = myComments
        self.myCategories = myCategories
        self.myTopics = myTopics
        self.badges = badges
        self.profilePhoto = profilePhoto
        self.myAccessedProfiles = myAccessedProfiles
        self.myTakeTime = myTakeTime
        self.lastLogin = lastLogin
        self.lastFeedRefresh = lastFeedRefresh
        self.attributes = [:]
        // Add logic to add one to streak if it is maintained, update in Firebase
        self.streak = streak
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id && lhs.userId == rhs.userId && lhs.username == rhs.username && lhs.phoneNumber == rhs.phoneNumber
    }
}
