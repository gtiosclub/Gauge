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
        
        let userDocument = Firebase.db.collection("USERS").document(userID)
        
        userDocument.updateData(["profilePhoto": FieldValue.delete()]) { error in
            if let error = error {
                print("Error updating document: \(error.localizedDescription)")
            }
        }
    }
    
    
}
