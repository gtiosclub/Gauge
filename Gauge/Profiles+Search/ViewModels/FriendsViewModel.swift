//
//  FriendsViewModel.swift
//  Gauge
//
//  Created by amber verma on 2/9/25.
//

import Foundation
import FirebaseFirestore

class FriendsViewModel: ObservableObject {
    @Published var friends: [String: [String]] = [:]
    @Published var incomingRequests: [String: [String]] = [:]
    @Published var outgoingRequests: [String: [String]] = [:]
    
    init(user: User) {
        self.friends = user.friends
        self.incomingRequests = user.friendIn
        self.outgoingRequests = user.friendOut
    }
    
    /// Fetches the list of friends for a given user
    func getConnections() {
     
    }
    
    /// Fetches incoming friend requests
    func getIncomingRequests(userId: String) async -> [User] {
        var incomingRequests = [User]()


        // 1: Query the 'friendIn' collection for the given userID
        // 2: implement error handling with if else statement, ?? for fallback value ? when calling function
        do {
            //snapshot of the user
            let snapshot = try await Firebase.db.collection("users").document(userId).getDocument()

            if let friendsIn = snapshot.data()?["friendIn"] as? [String: [String]] {
                
                for friendId in friendsIn.keys {
                    if let user = await getUserFromId(userId: friendId) {
                        incomingRequests.append(user)
                    }
                }
            } else {
                print("No incoming friends found for \(userId)")
            }
        } catch {
            print("Error fetching incoming friend requests \(error.localizedDescription)")
        }
        //return the array of incoming friend requests
        return incomingRequests;
    }
    
    
    /// Fetches outgoing friend requests
    func getOutgoingRequests(userId: String) async -> [User]? {
        do {
            let document = try await Firebase.db.collection("USERS").document(userId).getDocument()
            
            guard let data = document.data() else { return nil }
            guard let friendsOut = data["friendOut"] as? [String: [String]] else { return nil }
            
            var outgoingRequests = [User]()
            for friendId in friendsOut.keys {
                if let user = await getUserFromId(userId: friendId) {
                    outgoingRequests.append(user)
                }
            }
            
            return outgoingRequests
        } catch{
            print("Error getting document")
            return nil
        }
    }
    
    /// Searches for friends in a user’s list based on a given search string
    func searchFriends(userId: String, searchString: String) async -> [[String: Any]]? {
            do {
                let document = try await Firebase.db.collection("USERS").document(userId).getDocument()
                
                guard let data = document.data(), let friendIds = data["friends"] as? [String] else { return nil }
                
                var matchingFriends: [[String: Any]] = []
                let querySnapshot = try await Firebase.db.collection("USERS")
                    .whereField("userId", in: friendIds)
                    .getDocuments()
                
                for document in querySnapshot.documents {
                    let friendData = document.data()
                    if let username = friendData["username"] as? String,
                       username.lowercased().contains(searchString.lowercased()) {
                        matchingFriends.append(friendData)
                    }
                }
                
                return matchingFriends
            } catch {
                print("Error searching friends: \(error)")
                return nil
            }
        }
    
    func getUserFromId(userId: String) async -> User? {
        do {
            let document = try await Firebase.db.collection("USERS").document(userId).getDocument()
            guard let userData = document.data() else {return nil}
            
            guard let name = userData["name"] as? String else { return nil }
            guard let email = userData["email"] as? String else { return nil }
            
            let phoneNumber = userData["phoneNumber"] as? String
            let friendIn = userData["friendIn"] as? [String : [String]]
            let friendOut = userData["friendOut"] as? [String: [String]]
            let friends = userData["friends"] as? [String: [String]]
            let myPosts = userData["myPosts"] as? [String]
            let myResponses = userData["myResponses"] as? [String]
            let myReactions = userData["myReactions"] as? [String]
            let mySearches = userData["mySearches"] as? [String]
            let myComments = userData["myComments"] as? [String]
            let myCategories = userData["myCategories"] as? [String]
            let badges = userData["badges"] as? [String]
            let streak = userData["streak"] as? Int
            
            if let phoneNumber = phoneNumber,
               let friendIn = friendIn,
               let friendOut = friendOut,
               let friends = friends,
               let myPosts = myPosts,
               let myResponses = myResponses,
               let myReactions = myReactions,
               let mySearches = mySearches,
               let myComments = myComments,
               let myCategories = myCategories,
               let badges = badges,
               let streak = streak {
                let outputUser = try User(userId: userId, username: name, phoneNumber: phoneNumber, email: email,friendIn: friendIn, friendOut: friendOut, friends: friends, myPosts: myPosts, myResponses: myResponses, myReactions: myReactions, mySearches: mySearches, myComments: myComments, myCategories: myCategories, badges: badges, streak: streak)
                return outputUser
            } else {
                let outputUser = try User(userId: userId, username: name, email: email)
                return outputUser
            }
                
        } catch {
            return nil
        }
    }
}
