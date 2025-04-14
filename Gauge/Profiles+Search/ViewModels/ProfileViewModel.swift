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
    
    @Published var user: User?
    @Published var posts: [BinaryPost] = []
    
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
    
    func fetchUserPosts(for userId: String) {
            let db = Firestore.firestore()
            DispatchQueue.main.async {
                self.posts = []
            }
            
            db.collection("POSTS")
                .whereField("userId", isEqualTo: userId)
                .whereField("type", isEqualTo: PostType.BinaryPost.rawValue)
                .getDocuments { snapshot, error in
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
                        db.collection("POSTS").document(postId).collection("VIEWS")
                            .getDocuments { snapshot, error in
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
    
}
