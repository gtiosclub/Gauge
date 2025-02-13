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
    func getIncomingRequests(userID: String) async -> [String] {

        //initialize empty array to store incomingFriend requests
        var incomingFriends: [String] = []

        // 1: Query the 'friendIn' collection for the given userID
        // 2: implement error handling with if else statement, ?? for fallback value ? when calling function
        do {
            //snapshot of the user
            let snapshot = try await Firebase.db.collection("users").document(userID).getDocument()

            //? (optional chaining) attempts to get dictionary keys - all incoming friend requests from friendsIn key. ? prevents code from crashing if method fails, as (keyword for type conversion)
            if let friendsIn = snapshot.data()?["friendsIn"] as? [String] {
                //add each userID to the array
                //friendsIn is a temporary variable created by this if let statement
                incomingFriends.append(contentsOf: friendsIn)
            } else {
                print("No incoming friends found for \(userID)")
            }
        } catch {
            print("Error fetching incoming friend requests \(error.localizedDescription)")
        }

        //return the array of incoming friend requests
        return incomingFriends;
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
    func searchFriends() {
        
    }
}
