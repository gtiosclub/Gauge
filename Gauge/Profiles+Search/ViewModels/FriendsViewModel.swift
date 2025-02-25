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
            let snapshot = try await Firebase.db.collection("USERS").document(userId).getDocument()

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
    func searchFriends(userId: String, searchString: String) async -> [User]? {
            do {
                let document = try await Firebase.db.collection("USERS").document(userId).getDocument()
                
                guard let data = document.data(), let friendIds = data["friends"] as? [String] else { return nil }
                
                var matchingFriends: [User] = []
                let querySnapshot = try await Firebase.db.collection("USERS")
                    .whereField("userId", in: friendIds)
                    .getDocuments()
                
                for document in querySnapshot.documents {
                    let friendData = document.data()
                    if let username = friendData["username"] as? String,
                       username.lowercased().contains(searchString.lowercased()) {
                        let friendUserId = document.documentID
                        if let user = await getUserFromId(userId: friendUserId) {
                            matchingFriends.append(user)
                        }
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
            
            let phoneNumber = userData["phoneNumber"] as? String ?? ""
            let friendIn = userData["friendIn"] as? [String : [String]] ?? [:]
            let friendOut = userData["friendOut"] as? [String: [String]] ?? [:]
            let friends = userData["friends"] as? [String: [String]] ?? [:]
            let myPosts = userData["myPosts"] as? [String] ?? []
            let myResponses = userData["myResponses"] as? [String] ?? []
            let myReactions = userData["myReactions"] as? [String] ?? []
            let mySearches = userData["mySearches"] as? [String] ?? []
            let myComments = userData["myComments"] as? [String] ?? []
            let myCategories = userData["myCategories"] as? [String] ?? []
            let badges = userData["badges"] as? [String] ?? []
            let streak = userData["streak"] as? Int ?? 0
            
            let outputUser = try User(userId: userId, username: name, phoneNumber: phoneNumber, email: email,friendIn: friendIn, friendOut: friendOut, friends: friends, myPosts: myPosts, myResponses: myResponses, myReactions: myReactions, mySearches: mySearches, myComments: myComments, myCategories: myCategories, badges: badges, streak: streak)
            return outputUser
                
        } catch {
            return nil
        }
    }

    enum FriendRequestError: Error {
        case invalidData(reason: String)
        case userError(reason:String)
    }
    
    func acceptFriendRequest(friendId: String, hostId: String) async throws {
        do {
            let friendDocRef = Firebase.db.collection("USERS").document(friendId)
            let hostDocRef = Firebase.db.collection("USERS").document(hostId)
            async let friendDocumentSnapshot = friendDocRef.getDocument()
            async let hostDocumentSnapshot = hostDocRef.getDocument()
            
            let (friendSnapshot, hostSnapshot) = try await (friendDocumentSnapshot, hostDocumentSnapshot)
            
            // remove hostId from friend's outgoing requests
            guard let friendDocument = friendSnapshot.data() else {
                throw FriendRequestError.invalidData(reason: "Friend document not found")
            }
            guard var friendsOut = friendDocument["friendOut"] as? [String: [String]] else { throw FriendRequestError.invalidData(reason: "No outgoing request data for friend")}
            guard friendsOut.removeValue(forKey: hostId) != nil else {
                throw FriendRequestError.invalidData(reason: "Host is not in friend's outgoing requests")
            }
            // remove friendId from host's incoming requests
            guard let hostDocument = hostSnapshot.data() else {
                throw FriendRequestError.invalidData(reason: "Host document not found")
            }
            guard var hostIn = hostDocument["friendIn"] as? [String: [String]] else { throw FriendRequestError.invalidData(reason: "No incoming request data for host")}
            guard hostIn.removeValue(forKey: friendId) != nil else {
                throw FriendRequestError.invalidData(reason: "Friend is not in host's incoming requests")
            }
            
            // add host to freind's friends
            var friendFriends = friendDocument["friends"] as? [String: [String]] ?? [:]
            guard let hostUsername = hostDocument["username"] as? String else { throw FriendRequestError.userError(reason: "Host document does not contain username")}
            let hostProfilePhoto = hostDocument["profilePhoto"] as? String ?? ""
            friendFriends[hostId] = [hostUsername, hostProfilePhoto]
            
            // add friend to host's friends
            var hostFriends = hostDocument["friends"] as? [String: [String]] ?? [:]
            guard let friendUsername = friendDocument["username"] as? String else { throw FriendRequestError.userError(reason: "Friend document does not contain username")}
            let friendProfilePhoto = friendDocument["profilePhoto"] as? String ?? ""
            hostFriends[friendId] = [friendUsername, friendProfilePhoto]
            
            let batch = Firebase.db.batch()
            batch.updateData(["friendOut": friendsOut,"friends": friendFriends], forDocument: friendDocRef)
            batch.updateData(["friendIn": hostIn, "friends": hostFriends], forDocument: hostDocRef)

            try await batch.commit()
        } catch FriendRequestError.invalidData(let reason) {
            print("Data Error - \(reason)")
            throw FriendRequestError.invalidData(reason: reason)
        } catch FriendRequestError.userError(let reason) {
            print("User Error - \(reason)")
            throw FriendRequestError.userError(reason: reason)
        }
        catch {
            print("Unexpected Error")
            throw error
        }
    }

    func rejectFriendRequest(friendId: String, hostId: String) async throws {
        do {
            let batch = Firebase.db.batch()
            let friendDocRef = Firebase.db.collection("USERS").document(friendId)
            let hostDocRef = Firebase.db.collection("USERS").document(hostId)
            async let friendDocumentSnapshot = friendDocRef.getDocument()
            async let hostDocumentSnapshot = hostDocRef.getDocument()
            
            let (friendSnapshot, hostSnapshot) = try await (friendDocumentSnapshot, hostDocumentSnapshot)
            
            // remove hostId from friend's outgoing requests
            guard let friendDocument = friendSnapshot.data() else {
                throw FriendRequestError.invalidData(reason: "Friend document not found")
            }
            guard var friendsOut = friendDocument["friendOut"] as? [String: [String]] else { throw FriendRequestError.invalidData(reason: "No outgoing request data for friend")}
            guard friendsOut.removeValue(forKey: hostId) != nil else {
                throw FriendRequestError.invalidData(reason: "Host is not in friend's outgoing requests")
            }
            batch.updateData(["friendOut": friendsOut], forDocument: friendDocRef)
            
            // remove friendId from host's incoming requests
            guard let hostDocument = hostSnapshot.data() else {
                throw FriendRequestError.invalidData(reason: "Host document not found")
            }
            guard var hostIn = hostDocument["friendIn"] as? [String: [String]] else { throw FriendRequestError.invalidData(reason: "No incoming request data for host")}
            guard hostIn.removeValue(forKey: friendId) != nil else {
                throw FriendRequestError.invalidData(reason: "Friend is not in host's incoming requests")
            }
            batch.updateData(["friendIn": hostIn], forDocument: hostDocRef)

            try await batch.commit()

        } catch FriendRequestError.invalidData(let reason) {
            print("Data Error - \(reason)")
            throw FriendRequestError.invalidData(reason: reason)
        } catch FriendRequestError.userError(let reason) {
            print("User Error - \(reason)")
            throw FriendRequestError.userError(reason: reason)
        }
        catch {
            print("Unexpected Error")
            throw error
        }
    }
}
