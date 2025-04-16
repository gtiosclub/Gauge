//
//  ProfileViewModel.swift
//  Gauge
//
//  Created by amber verma on 2/13/25.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage
import UIKit

class ProfileViewModel: ObservableObject {
    @Published var tempAttributes: [String:String] = [:]
    @Published var user: User?
    @Published var posts: [BinaryPost] = []
    @Published var respondedPosts: [BinaryPost] = []
    @Published var visitedStats: (totalVotes: Int, totalComments: Int, totalTakes: Int, viewResponseRatio: Double) =
        (0, 0, 0, 0.0)
    
    private var storage = Storage.storage()
    
    func storeImageAndReturnURL(userId: String, image: UIImage) async -> String? {
        guard let imageData = image.jpegData(compressionQuality: 0.75) else {
            print("Couldn't convert image to data")
            return nil
        }
        
        let storageRef = storage.reference().child("images/\(userId).jpg")
        
        do {
            _ = try await storageRef.putDataAsync(imageData)
            
            let url = try await storageRef.downloadURL()
            return url.absoluteString
        } catch {
            print("Couldn't upload image: \(error.localizedDescription)")
            return nil
        }
    }
    
    func getImageFromURL(from urlString: String) async -> UIImage? {
        guard let url = URL(string: urlString) else {
            print("The URL is invalid.")
            return nil
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            if let image = UIImage(data: data) {
                return image
            } else {
                print("Couldn't convert data to image.")
                return nil
            }
        } catch {
            print("Couldn't fetch image from URL: \(error.localizedDescription)")
            return nil
        }
    }
    
    func removeAndReturn(userId: String) async -> Bool {
        let storageRef = storage.reference().child("images/\(userId).jpg")
        
        do {
            try await storageRef.delete()
            print("Profile picture deleted.")
            return true
        } catch {
            print("Couldn't delete profile picture: \(error.localizedDescription)")
            return false
        }
    }
    
    func updateProfilePicture(userID: String, image: UIImage) async -> String? {
        guard let profilePhotoURL = await storeImageAndReturnURL(userId: userID, image: image) else {
            print("Failed to get download URL")
            return nil
        }
        
        let userDocument = Firebase.db.collection("USERS").document(userID)
        do {
            try await userDocument.updateData([
                "profilePhoto": profilePhotoURL,
                "attributes.profileEmoji": FieldValue.delete() // Remove emoji when setting photo
            ])
            print("Document successfully updated")
            return profilePhotoURL
        } catch {
            print("Error updating document: \(error.localizedDescription)")
            return nil
        }
    }

    
    func removeProfilePicture(userID: String) async -> Bool {
        let userDocument = Firebase.db.collection("USERS").document(userID)
        
        do {
            try await userDocument.updateData([
                "profilePhoto": FieldValue.delete(),
                "attributes.profileEmoji": FieldValue.delete() // Remove emoji as well
            ])
            print("Profile fields removed from Firestore")
        } catch {
            print("Error updating fields: \(error.localizedDescription)")
            return false
        }
        
        let removed = await removeAndReturn(userId: userID)
        if !removed {
            print("Failed to successfully remove profile picture from Storage")
        }
        
        return removed
    }
    

    func getProfilePicture(userID: String) async -> UIImage? {
        let userDocument = Firebase.db.collection("USERS").document(userID)
        
        do {
            let document = try await userDocument.getDocument()
            if let data = document.data(), let urlString = data["profilePhoto"] as? String {
                return await getImageFromURL(from: urlString)
            } else {
                print("Document does not exist or URL could not be retrieved")
            }
        } catch {
            print("Error fetching document: \(error.localizedDescription)")
        }
        return nil
    }
    
    func updateProfilePhotoAndAttributes(userID: String,
                                         username: String,
                                         bio: String,
                                         pronouns: String,
                                         profileImage: UIImage?) async -> Bool {
        // If a new profile image was provided, upload it and get its URL.
        var photoURL: String? = nil
        if let profileImage = profileImage {
            photoURL = await storeImageAndReturnURL(userId: userID, image: profileImage)
        }
        
        // Build the attributes dictionary (all keys except profileEmoji are updated).
        // tempAttributes holds values from the various attribute-detail screens.
        let userAttributes: [String: String] = [
            "gender": tempAttributes["gender"] ?? "",
            "location": tempAttributes["location"] ?? "",
            "pronouns": pronouns,  // using the value from the main form
            "age": tempAttributes["age"] ?? "",
            "height": tempAttributes["height"] ?? "",
            "relationshipStatus": tempAttributes["relationshipStatus"] ?? "",
            "workStatus": tempAttributes["workStatus"] ?? "",
            "bio": bio
        ]
        
        // Build the updates dictionary. If a new photoURL exists, include it.
        var updates: [String: Any] = [
            "username": username,
            "attributes": userAttributes
        ]
        if let photoURL = photoURL {
            updates["profilePhoto"] = photoURL
        }
        
        // Perform one combined update on Firestore.
        let userDocument = Firebase.db.collection("USERS").document(userID)
        do {
            try await userDocument.updateData(updates)
            print("Profile photo, username, and attributes updated successfully.")
            return true
        } catch {
            print("Error updating profile: \(error.localizedDescription)")
            return false
        }
    }
    
    func fetchUserPosts(for userId: String) {
            let db = Firestore.firestore()
            DispatchQueue.main.async {
                self.posts = []
            }
            
            db.collection("POSTS").whereField("userId", isEqualTo: userId).whereField("type", isEqualTo: PostType.BinaryPost.rawValue).getDocuments { snapshot, error in
                    if let error = error {
                        print("Error fetching posts: \(error.localizedDescription)")
                        return
                    }
                    guard let documents = snapshot?.documents else {
                        print("No posts found")
                        return
                    }
                    
                    var fetchedPosts: [BinaryPost] = []
                    let group = DispatchGroup()

                    for document in documents {
                        let data = document.data()
                        let postId = document.documentID
                        
                        // Convert Firestore data to a BinaryPost
                        let postDate = (data["postDateAndTime"] as? Timestamp)?.dateValue() ??
                            DateConverter.convertStringToDate(data["postDateAndTime"] as? String ?? "") ?? Date()
                        
                        var post = BinaryPost(
                            postId: postId,
                            userId: data["userId"] as? String ?? "",
                            categories: Category.mapStringsToCategories(returnedStrings: data["categories"] as? [String] ?? []),
                            topics: data["topics"] as? [String] ?? [],
                            postDateAndTime: postDate,
                            question: data["question"] as? String ?? "",
                            responseOption1: data["responseOption1"] as? String ?? "",
                            responseOption2: data["responseOption2"] as? String ?? "",
                            sublabel1: data["sublabel1"] as? String ?? "",
                            sublabel2: data["sublabel2"] as? String ?? "",
                            favoritedBy: data["favoritedBy"] as? [String] ?? []
                        )
                        
                        // Fetch RESPONSES
                        group.enter()
                        db.collection("POSTS").document(postId).collection("RESPONSES").getDocuments { snapshot, error in
                                if let snapshot = snapshot {
                                    let responses: [Response] = snapshot.documents.compactMap { doc in
                                        let d = doc.data()
                                        return Response(
                                            responseId: doc.documentID,
                                            userId: d["userId"] as? String ?? "",
                                            responseOption: d["responseOption"] as? String ?? ""
                                        )
                                    }
                                    post.responses = responses
                                }
                                group.leave()
                            }
                        
                        // Fetch COMMENTS
                        group.enter()
                        db.collection("POSTS").document(postId).collection("COMMENTS").getDocuments { snapshot, error in
                                if let snapshot = snapshot {
                                    let comments: [Comment] = snapshot.documents.compactMap { doc in
                                        let d = doc.data()
                                        return Comment(
                                            commentType: .text,
                                            postId: postId,
                                            userId: d["userId"] as? String ?? "",
                                            username: "",
                                            profilePhoto: "",
                                            date: DateConverter.convertStringToDate(d["date"] as? String ?? "") ?? Date(),
                                            commentId: doc.documentID,
                                            likes: d["likes"] as? [String] ?? [],
                                            dislikes: d["dislikes"] as? [String] ?? [],
                                            content: d["content"] as? String ?? ""
                                        )
                                    }
                                    post.comments = comments
                                }
                                group.leave()
                            }
                        
                        // Fetch VIEWS
                        group.enter()
                        db.collection("POSTS").document(postId).collection("VIEWS").getDocuments { snapshot, error in
                                if let snapshot = snapshot {
                                    post.viewCounter = snapshot.documents.count
                                }
                                group.leave()
                            }
                        
                        group.notify(queue: .main) {
                            fetchedPosts.append(post)
                            self.posts = fetchedPosts.sorted { $0.postDateAndTime > $1.postDateAndTime }
                        }
                    }
                }
        }
    
    func fetchRespondedPosts(for userId: String, using userVM: UserFirebase) async {
        do {
            let (responseIds, _, _) = try await userVM.getUserPostInteractions(userId: userId, setCurrentUserData: false)
            print("✅ Got \(responseIds.count) response post IDs")
            
            let limitedIds = Array(responseIds.prefix(10)) 
            var tempPosts: [BinaryPost] = []
            
            await withTaskGroup(of: BinaryPost?.self) { group in
                for id in limitedIds {
                    group.addTask {
                        do {
                            let doc = try await Firebase.db.collection("POSTS").document(id).getDocument()
                            guard let data = doc.data(),
                                  let type = data["type"] as? String,
                                  type == PostType.BinaryPost.rawValue else { return nil }

                            var post = BinaryPost(
                                postId: id,
                                userId: data["userId"] as? String ?? "",
                                categories: Category.mapStringsToCategories(returnedStrings: data["categories"] as? [String] ?? []),
                                topics: data["topics"] as? [String] ?? [],
                                postDateAndTime: (data["postDateAndTime"] as? Timestamp)?.dateValue()
                                    ?? DateConverter.convertStringToDate(data["postDateAndTime"] as? String ?? "") ?? Date(),
                                question: data["question"] as? String ?? "",
                                responseOption1: data["responseOption1"] as? String ?? "",
                                responseOption2: data["responseOption2"] as? String ?? "",
                                sublabel1: data["sublabel1"] as? String ?? "",
                                sublabel2: data["sublabel2"] as? String ?? "",
                                favoritedBy: data["favoritedBy"] as? [String] ?? []
                            )
                            post.username = data["username"] as? String ?? "Unknown"
                            post.profilePhoto = data["profilePhoto"] as? String ?? ""

                            // ✅ Only get the current user's response
                            let responseSnap = try await Firebase.db.collection("POSTS").document(id).collection("RESPONSES")
                                .whereField("userId", isEqualTo: userId).getDocuments()

                            post.responses = responseSnap.documents.map { d in
                                let data = d.data()
                                return Response(
                                    responseId: data["responseId"] as? String ?? UUID().uuidString,
                                    userId: data["userId"] as? String ?? "",
                                    responseOption: data["responseOption"] as? String ?? ""
                                )
                            }

                            return post
                        } catch {
                            print("⚠️ Failed to fetch post with ID \(id): \(error.localizedDescription)")
                            return nil
                        }
                    }
                }

                for await post in group {
                    if let post = post {
                        tempPosts.append(post)
                    }
                }
            }

            print("✅ Fetched \(tempPosts.count) posts. Sorting and storing...")
            let sortedPosts = tempPosts.sorted { $0.postDateAndTime > $1.postDateAndTime }

            await MainActor.run {
                self.respondedPosts = sortedPosts
            }

        } catch {
            print("🔥 Failed to fetch responded posts: \(error.localizedDescription)")
        }
    }
    
    func fetchVisitedStats(for user: User, using userVM: UserFirebase) async {
        do {
            async let (responses, comments, _) = userVM.getUserPostInteractions(userId: user.userId, setCurrentUserData: false)
            async let posts = userVM.getUserPosts(userId: user.userId, setCurrentUserData: false)

            let (res, com, postIds) = try await (responses, comments, posts)

            let viewCount = user.myViews.count
            let responseCount = res.count
            let ratio = responseCount == 0 ? 0.0 : Double(viewCount) / Double(responseCount)

            await MainActor.run {
                self.visitedStats = (
                    totalVotes: responseCount,
                    totalComments: com.count,
                    totalTakes: postIds.count,
                    viewResponseRatio: ratio
                )
            }
        } catch {
            print("❌ Failed to load visited user stats: \(error.localizedDescription)")
        }
    }
}
