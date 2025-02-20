//
//  ProfileViewModel.swift
//  Gauge
//
//  Created by amber verma on 2/13/25.
//

import Foundation
import FirebaseFirestore

class ProfileViewModel: ObservableObject {
    @Published var user: User?
    
    init() {
        
    }
    
    
    
    //store the image URL that is provided by FirebaseStorage
    //add/update profile picture
    func updateProfilePicture(userID: String, image: UIImage) async -> Void {
        //update profilePhoto field
        guard let profilePhoto = storeImageAndReturnURL(image: image) else {
            print("Failed to get download URL")
            return
        }
        //update profile picture in firestore
        let userDocument = Firebase.db.collection("USERS").document(userID)
        userDocument.updateData(["profilePhoto": profilePhoto]) { error in
            if let error = error {
                print("Error updating document: \(error.localizedDescription)")
            } else {
                print("Document successfully updated")
            }
        }
        
    }
    
    
    //remove profile picture
    func removeProfilePicture(userID: String) async -> Void {
        
        //update profile picture in firestore
        let userDocument = Firebase.db.collection("USERS").document(userID)
        
        //delete data in database
        userDocument.updateData(["profilePhoto": FieldValue.delete()]) { error in
            if let error = error {
                print("Error updating document: \(error.localizedDescription)")
            } else {
                print("Document successfully updated")
            }
        }
        
        //removeAndReturn returns true if image successfully removed from firebaseStorage
        guard let removed = removeAndReturn(userID) else {
            print("failed to successfully remove profile picture")
        }

    }
    
    
    
    //get pfp function
    func getProfilePicture(userID: String) async -> Void {
        //user
        let userDocument = Firebase.db.collection("USERS").document(userID)
        
        do {
            let document = try await userDocument.getDocument()
            if let data = document.data(),
               let urlString = data["profilePicture"] as? String {
                return await getImageFromURL(urlString: urlString)
            } else {
                print("Document does not exist or URL could not be retrieved")
            }
        } catch {
            print("Error fetching document: \(error.localizedDescription)")
        }
    }
    
    
}
