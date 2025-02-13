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
    func getIncomingRequests() {
       
    }
    
    /// Fetches outgoing friend requests
    func getOutgoingRequests(userId: String) async -> [String]? {
        do {
            let document = try await Firebase.db.collection("USERS").document(userId).getDocument()
            
            guard let data = document.data() else { return nil }
            guard let friendsOut = data["friendsOut"] as? [String] else { return nil }
            
            return friendsOut
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
            let outputUser = try User(userId: userId, username: name, email: email)
            
            return outputUser
        } catch {
            return nil
        }
    }
}
