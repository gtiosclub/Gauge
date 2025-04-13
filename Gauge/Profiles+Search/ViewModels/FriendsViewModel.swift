//
//  FriendsViewModel.swift
//  Gauge
//
//  Created by amber verma on 2/9/25.
//

import Foundation
import FirebaseFirestore

class FriendsViewModel: ObservableObject {
    @Published var friends: [String] = []
    @Published var incomingRequests: [String] = []
    @Published var outgoingRequests: [String] = []
    
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
            guard let friendsOut = data["friendOut"] as? [String] else { return nil }
            
            var outgoingRequests = [User]()
            for friendId in friendsOut {
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
    
    /// Sends a friend request from one user to another
    func sendFriendRequest(from senderId: String, to receiverId: String) async throws {
        let senderRef = Firebase.db.collection("USERS").document(senderId)
        let receiverRef = Firebase.db.collection("USERS").document(receiverId)

        do {
            // Fetch the receiver’s data
            let receiverSnapshot = try await receiverRef.getDocument()
            guard let receiverData = receiverSnapshot.data() else {
                throw NSError(domain: "sendFriendRequest", code: 404, userInfo: [NSLocalizedDescriptionKey: "Receiver not found"])
            }

            var friendIn = receiverData["friendIn"] as? [String: [String]] ?? [:]
            if friendIn[senderId] == nil {
                friendIn[senderId] = ["Pending"]
                try await receiverRef.updateData(["friendIn": friendIn])
            }

            // Fetch the sender’s data
            let senderSnapshot = try await senderRef.getDocument()
            guard let senderData = senderSnapshot.data() else {
                throw NSError(domain: "sendFriendRequest", code: 404, userInfo: [NSLocalizedDescriptionKey: "Sender not found"])
            }

            var friendOut = senderData["friendOut"] as? [String: [String]] ?? [:]
            if friendOut[receiverId] == nil {
                friendOut[receiverId] = ["Pending"]
                try await senderRef.updateData(["friendOut": friendOut])
            }

            print("Friend request sent successfully")
        } catch {
            throw error
        }
    }

    
    func getUserFromId(userId: String) async -> User? {
        do {
            let document = try await Firebase.db.collection("USERS").document(userId).getDocument()
            guard let userData = document.data() else {return nil}
            
            guard let username = userData["username"] as? String else { return nil }
            guard let email = userData["email"] as? String else { return nil }

            let phoneNumber = userData["phoneNumber"] as? String ?? ""
            let friendIn = userData["friendIn"] as? [String] ?? []
            let friendOut = userData["friendOut"] as? [String] ?? []
            let friends = userData["friends"] as? [String] ?? []
            let myNextPosts = userData["myNextPosts"] as? [String] ?? []
            let myResponses = userData["myResponses"] as? [String] ?? []
            let myFavorites = userData["myFavorites"] as? [String] ?? []
            let myPostSearches = userData["myPostSearches"] as? [String] ?? []
            let myProfileSearches = userData["myProfileSearches"] as? [String] ?? []
            let myComments = userData["myComments"] as? [String] ?? []
            let myCategories = userData["myCategories"] as? [String] ?? []
            let myTopics = userData["myTopics"] as? [String] ?? []
            let myAccessedProfiles = userData["myAccessedProfiles"] as? [String] ?? []
            let badges = userData["badges"] as? [String] ?? []
            let streak = userData["streak"] as? Int ?? 0
            let lastLogin = DateConverter.convertStringToDate(userData["lastLogin"] as? String ?? "") ?? Date()
            let lastFeedRefresh = DateConverter.convertStringToDate(userData["lastFeedRefresh"] as? String ?? "") ?? Date()
            let attributes = userData["attributes"] as? [String : String] ?? [:]
            let profilePhoto = userData["profilePhoto"] as? String ?? ""
            let myTakeTime = userData["myTakeTime"] as? [String:Int] ?? [:]

            let outputUser = User(
                userId: userId,
                username: username,
                phoneNumber: phoneNumber,
                email: email,
                friendIn: friendIn,
                friendOut: friendOut,
                friends: friends,
                myNextPosts: myNextPosts,
                myResponses: myResponses,
                myFavorites: myFavorites,
                myPostSearches: myPostSearches,
                myProfileSearches: myProfileSearches,
                myComments: myComments,
                myCategories: myCategories,
                myTopics: myTopics,
                badges: badges,
                streak: streak,
                profilePhoto: profilePhoto,
                myAccessedProfiles: myAccessedProfiles,
                lastLogin: lastLogin,
                lastFeedRefresh: lastFeedRefresh,
                attributes: attributes,
                myTakeTime: myTakeTime
            )
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
