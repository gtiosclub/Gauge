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
    func getIncomingRequests(userID: String, completion: @escaping ([[String: Any]]) -> Void) {
        var incomingFriends: [[String: Any]] = []

        // Step 1: Query the 'friendIn' collection for the given userID
        Firebase.db.collection("friendsIn").document(userID).getDocument { snapshot, error in
            if let error = error {
                print("Error fetching friend requests: \(error)")
                completion([])
                return
            }

            guard let data = snapshot?.data() else {
                print("No friend requests found for \(userID)")
                completion([])
                return
            }

            let group = DispatchGroup() // Used to manage multiple async calls

            // Step 2: Fetch user details for each friendID
            for (friendID, _) in data {
                group.enter()
                Firebase.db.collection("users").document(friendID).getDocument { userSnapshot, userError in
                    if let userError = userError {
                        print("Error fetching user details for \(friendID): \(userError)")
                    } else if let userData = userSnapshot?.data() {
                        incomingFriends.append(userData)
                    }
                    group.leave()
                }
            }

            // Step 3: Return the result once all calls are complete
            group.notify(queue: .main) {
                completion(incomingFriends)
            }
        }
    }

    
    
    

    
    /// Fetches outgoing friend requests
    func getOutgoingRequests() {
        
    }
    
    /// Searches for friends in a user’s list based on a given search string
    func searchFriends() {
        
    }
}
