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
    
    private var db = Firestore.firestore()
    private var storage = Storage.storage()
    
    func storeImageAndReturnURL(userId: String, image: UIImage) async -> String? {
        
        // firebase storage accepts image in data format
        guard let imageData = image.jpegData(compressionQuality: 0.75) else {
            print("couldn't convert image to data")
            return nil
        }
        
        // reference to file in storage
        let storageRef = storage.reference().child("profilePictures/\(userId).jpg")
        
        do {
            // upload image to storage
            _ = try await storageRef.putDataAsync(imageData)
            
            // getting the url
            let url = try await storageRef.downloadURL()
            return url.absoluteString
        } catch {
            print("couldn't upload image: \(error.localizedDescription)")
            return nil
        }
        
    }
    
    func getImageFromURL(from urlString: String) async -> UIImage? {
        
        guard let url = URL(string: urlString) else {
            print("the URL is invalid.")
            return nil
        }
        
        do {
            // fetch image from URL
            let (data, _) = try await URLSession.shared.data(from: url)
            
            // convert data to image
            if let image = UIImage(data: data) {
                return image
            } else {
                print("couldn't convert data to image.")
                return nil
            }
        } catch {
            print("couldn't fetch image from URL: \(error.localizedDescription)")
            return nil
        }
        
    }
    
    func removeAndReturn(userId: String) async -> Bool {
        
        let storageRef = storage.reference().child("profilePictures/\(userId).jpg")
        
        do {
            // delete image from storage
            try await storageRef.delete()
            print("profile picture deleted.")
            return true
        } catch {
            print("couldn't delete profile picture: \(error.localizedDescription)")
            return false
        }
        
    }
    
    //store the image URL that is provided by FirebaseStorage
    //add/update profile picture
    //    func updateProfilePicture(userID: String, image: UIImage) async -> Void {
    //        //update profilePhoto field
    //        guard let profilePhoto = storeImageAndReturnURL(image: image) else {
    //            print("Failed to get download URL")
    //            return
    //        }
    //        //update profile picture in firestore
    //        let userDocument = Firebase.db.collection("USERS").document(userID)
    //        userDocument.updateData(["profilePhoto": profilePhoto]) { error in
    //            if let error = error {
    //                print("Error updating document: \(error.localizedDescription)")
    //            } else {
    //                print("Document successfully updated")
    //            }
    //        }
    //
    //    }
    //
    
    //remove profile picture
    //    func removeProfilePicture(userID: String) async -> Bool {
    //
    //        //update profile picture in firestore
    //        let userDocument = Firebase.db.collection("USERS").document(userID)
    //
    //        do {
    //            //delete data in database
    //            try await userDocument.updateData(["profilePhoto": FieldValue.delete()])
    //            print("Profile Picture updated!")
    //        } catch {
    //            print("Error updating Profile Picture: \(error.localizedDescription)")
    //            return false
    //        }
    //
    //        //removeAndReturn returns true if image successfully removed from firebaseStorage
    //        let removed = await removeAndReturn(userID)
    //        if !removed {
    //            print("failed to successfully remove profile picture")
    //        }
    //
    //        return removed
    //    }
    
    
    
    //get pfp function
    //    func getProfilePicture(userID: String) async -> UIImage {
    //        //user
    //        let userDocument = Firebase.db.collection("USERS").document(userID)
    //
    //        do {
    //            let document = try await userDocument.getDocument()
    //            if let data = document.data(),
    //               let urlString = data["profilePicture"] as? String {
    //                return await getImageFromURL(urlString: urlString)
    //            } else {
    //                print("Document does not exist or URL could not be retrieved")
    //            }
    //        } catch {
    //            print("Error fetching document: \(error.localizedDescription)")
    //        }
    //
    //    }
    
    //store the image URL that is provided by FirebaseStorage
    //add/update profile picture
    //    func updateProfilePicture(userID: String, image: UIImage) async -> Void {
    //        //update profilePhoto field
    //        guard let profilePhoto = storeImageAndReturnURL(image: image) else {
    //            print("Failed to get download URL")
    //            return
    //        }
    //        //update profile picture in firestore
    //        let userDocument = Firebase.db.collection("USERS").document(userID)
    //        userDocument.updateData(["profilePhoto": profilePhoto]) { error in
    //            if let error = error {
    //                print("Error updating document: \(error.localizedDescription)")
    //            } else {
    //                print("Document successfully updated")
    //            }
    //        }
    //
    //    }
    //
    
    //remove profile picture
    //    func removeProfilePicture(userID: String) async -> Bool {
    //
    //        //update profile picture in firestore
    //        let userDocument = Firebase.db.collection("USERS").document(userID)
    //
    //        do {
    //            //delete data in database
    //            try await userDocument.updateData(["profilePhoto": FieldValue.delete()])
    //            print("Profile Picture updated!")
    //        } catch {
    //            print("Error updating Profile Picture: \(error.localizedDescription)")
    //            return false
    //        }
    //
    //        //removeAndReturn returns true if image successfully removed from firebaseStorage
    //        let removed = await removeAndReturn(userID)
    //        if !removed {
    //            print("failed to successfully remove profile picture")
    //        }
    //
    //        return removed
    //    }
    
    
    
    //get pfp function
    //    func getProfilePicture(userID: String) async -> UIImage {
    //        //user
    //        let userDocument = Firebase.db.collection("USERS").document(userID)
    //
    //        do {
    //            let document = try await userDocument.getDocument()
    //            if let data = document.data(),
    //               let urlString = data["profilePicture"] as? String {
    //                return await getImageFromURL(urlString: urlString)
    //            } else {
    //                print("Document does not exist or URL could not be retrieved")
    //            }
    //        } catch {
    //            print("Error fetching document: \(error.localizedDescription)")
    //        }
    //
    //    }
}
