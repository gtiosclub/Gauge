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
    @Published var loadedFriends: [User] = []
    @Published var loadedRequests: [User] = []

    init(user: User) {
        self.friends = user.friends
        self.incomingRequests = user.friendIn
        self.outgoingRequests = user.friendOut
        
        Task {
            await fetchFriendsDetails()
            await fetchIncomingRequestDetails(userId: user.userId)
        }
    }

    func getIncomingRequests(userId: String) async -> [User] {
        var incoming: [User] = []

        do {
            let snapshot = try await Firebase.db.collection("USERS").document(userId).getDocument()
            let friendIn = snapshot.data()?["friendIn"] as? [String] ?? []

            for id in friendIn {
                        let cleanedId = id.trimmingCharacters(in: .whitespacesAndNewlines)
                        if let user = await getUserFromId(userId: cleanedId) {
                            incoming.append(user)
                        } else {
                            print("❌ Could not find user for incoming request id: \(cleanedId)")
                        }
                    }
                } catch {
                    print("Error fetching incoming requests: \(error)")
                }

                return incoming
            }

    func getOutgoingRequests(userId: String) async -> [User] {
        var outgoing: [User] = []

        do {
            let snapshot = try await Firebase.db.collection("USERS").document(userId).getDocument()
            let friendOut = snapshot.data()?["friendOut"] as? [String] ?? []

            for id in friendOut {
                if let user = await getUserFromId(userId: id) {
                    outgoing.append(user)
                }
            }
        } catch {
            print("Error fetching outgoing requests: \(error)")
        }

        return outgoing
    }

    func fetchIncomingRequestDetails(userId: String) async {
        let users = await getIncomingRequests(userId: userId)
        await MainActor.run {
            self.incomingRequests = users.map { $0.userId }
            self.loadedRequests = users
        }
        print("📨 Incoming loaded: \(users.map { $0.username })")
    }

    func fetchFriendsDetails() async {
        print("🔄 BEGIN fetchFriendsDetails with ids: \(friends)")

        await MainActor.run {
            self.loadedFriends = []
        }

        for id in friends {
            print("📡 Fetching friend user for id: \(id)")
            if let user = await getUserFromId(userId: id) {
                print("✅ Got user: \(user.username)")
                await MainActor.run {
                    self.loadedFriends.append(user)
                }
            } else {
                print("❌ No user found for id: \(id)")
            }
        }

        print("🎯 Final loadedFriends: \(loadedFriends.map { $0.username })")
    }


    func acceptFriendRequest(friendId: String, hostId: String) async throws {
        let hostRef = Firebase.db.collection("USERS").document(hostId)
        let friendRef = Firebase.db.collection("USERS").document(friendId)

        async let hostSnap = hostRef.getDocument()
        async let friendSnap = friendRef.getDocument()
        let (hostDataSnap, friendDataSnap) = try await (hostSnap, friendSnap)

        var hostIn = hostDataSnap.data()?["friendIn"] as? [String] ?? []
        var hostFriends = hostDataSnap.data()?["friends"] as? [String] ?? []

        var friendOut = friendDataSnap.data()?["friendOut"] as? [String] ?? []
        var friendFriends = friendDataSnap.data()?["friends"] as? [String] ?? []

        hostIn.removeAll { $0 == friendId }
        friendOut.removeAll { $0 == hostId }

        if !hostFriends.contains(friendId) {
            hostFriends.append(friendId)
        }

        if !friendFriends.contains(hostId) {
            friendFriends.append(hostId)
        }

        let batch = Firebase.db.batch()
        batch.updateData(["friendIn": hostIn, "friends": hostFriends], forDocument: hostRef)
        batch.updateData(["friendOut": friendOut, "friends": friendFriends], forDocument: friendRef)
        try await batch.commit()
    }

    func rejectFriendRequest(friendId: String, hostId: String) async throws {
        let hostRef = Firebase.db.collection("USERS").document(hostId)
        let friendRef = Firebase.db.collection("USERS").document(friendId)

        async let hostSnap = hostRef.getDocument()
        async let friendSnap = friendRef.getDocument()
        let (hostDataSnap, friendDataSnap) = try await (hostSnap, friendSnap)

        var hostIn = hostDataSnap.data()?["friendIn"] as? [String] ?? []
        var friendOut = friendDataSnap.data()?["friendOut"] as? [String] ?? []

        hostIn.removeAll { $0 == friendId }
        friendOut.removeAll { $0 == hostId }

        let batch = Firebase.db.batch()
        batch.updateData(["friendIn": hostIn], forDocument: hostRef)
        batch.updateData(["friendOut": friendOut], forDocument: friendRef)
        try await batch.commit()
    }

    func removeFriend(friendId: String, hostId: String) async throws {
        let hostRef = Firebase.db.collection("USERS").document(hostId)
        let friendRef = Firebase.db.collection("USERS").document(friendId)

        async let hostSnap = hostRef.getDocument()
        async let friendSnap = friendRef.getDocument()
        let (hostDoc, friendDoc) = try await (hostSnap, friendSnap)

        var hostFriends = hostDoc.data()?["friends"] as? [String] ?? []
        var friendFriends = friendDoc.data()?["friends"] as? [String] ?? []

        hostFriends.removeAll { $0 == friendId }
        friendFriends.removeAll { $0 == hostId }

        let batch = Firebase.db.batch()
        batch.updateData(["friends": hostFriends], forDocument: hostRef)
        batch.updateData(["friends": friendFriends], forDocument: friendRef)
        try await batch.commit()

        await MainActor.run {
            self.loadedFriends.removeAll { $0.userId == friendId }
        }
    }

    func getUserFromId(userId: String) async -> User? {
        do {
            let doc = try await Firebase.db.collection("USERS").document(userId).getDocument()
            guard let data = doc.data() else { return nil }

            let username = data["username"] as? String ?? "Unknown"
            let email = data["email"] as? String ?? ""
            let phone = data["phoneNumber"] as? String ?? ""
            let profilePhoto = data["profilePhoto"] as? String ?? ""

            return User(
                userId: userId,
                username: username,
                phoneNumber: phone,
                email: email,
                friendIn: data["friendIn"] as? [String] ?? [],
                friendOut: data["friendOut"] as? [String] ?? [],
                friends: data["friends"] as? [String] ?? [],
                myNextPosts: data["myNextPosts"] as? [String] ?? [],
                myResponses: data["myResponses"] as? [String] ?? [],
                myFavorites: data["myFavorites"] as? [String] ?? [],
                myPostSearches: data["myPostSearches"] as? [String] ?? [],
                myProfileSearches: data["myProfileSearches"] as? [String] ?? [],
                myComments: data["myComments"] as? [String] ?? [],
                myCategories: data["myCategories"] as? [String] ?? [],
                myTopics: data["myTopics"] as? [String] ?? [],
                badges: data["badges"] as? [String] ?? [],
                streak: data["streak"] as? Int ?? 0,
                profilePhoto: profilePhoto,
                myAccessedProfiles: data["myAccessedProfiles"] as? [String] ?? [],
                lastLogin: DateConverter.convertStringToDate(data["lastLogin"] as? String ?? "") ?? Date(),
                lastFeedRefresh: DateConverter.convertStringToDate(data["lastFeedRefresh"] as? String ?? "") ?? Date(),
                attributes: data["attributes"] as? [String: String] ?? [:]
            )
        } catch {
            return nil
        }
    }

    enum FriendRequestError: Error {
        case invalidData(reason: String)
        case userError(reason: String)
    }
}
