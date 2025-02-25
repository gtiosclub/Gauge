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
