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
    
    var friendIn: [String : [String]] = [:] // Key is userId, String array holds [username, profilePhotoString]
    var friendOut: [String : [String]] = [:] // Key is userId, String array holds [username, profilePhotoString]
    var friends: [String : [String]] = [:] // Key is userId, String array holds [username, profilePhotoString]
    var badges: [String] = []
    var profilePhoto: String
    var phoneNumber: String = ""
    var myCategories: [String] = []
    var myNextPosts: [String] = []
    
    // MARK: AI Algorithm Variables
    var myPosts: [String] = [] // PostIds of the user's posts
    var myResponses: [String] = [] // PostIds of those responded to
    var myViews: [String] = [] // PostIds of those skipped
    var myFavorites: [String] = [] // PostIds of those favorited
    var myComments: [String] = [] // PostIds of those commented on
    var mySearches: [String] = [] // Search queries
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
    
    init(userId: String, username: String, phoneNumber: String, email: String, friendIn: [String : [String]], friendOut: [String : [String]], friends: [String : [String]], myNextPosts: [String], myResponses: [String] = [], myFavorites: [String], mySearches: [String], myComments: [String] = [], myCategories: [String], badges: [String], streak: Int, profilePhoto: String = "", myAccessedProfiles: [String], lastLogin: Date, lastFeedRefresh: Date, attributes: [String: String]) {
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
        self.mySearches = mySearches
        self.myComments = myComments
        self.myCategories = myCategories
        self.badges = badges
        self.profilePhoto = profilePhoto
        self.myAccessedProfiles = myAccessedProfiles
        self.lastLogin = lastLogin
        self.lastFeedRefresh = lastFeedRefresh
        self.attributes = [:]
        // Add logic to add one to streak if it is maintained, update in Firebase
        self.streak = streak
        self.attributes = attributes
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id && lhs.userId == rhs.userId && lhs.username == rhs.username && lhs.phoneNumber == rhs.phoneNumber
    }
}
