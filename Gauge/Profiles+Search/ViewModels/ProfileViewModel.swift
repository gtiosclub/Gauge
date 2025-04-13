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
}
