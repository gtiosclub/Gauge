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
    @Published var profileImage: UIImage? // current profile picture
    
    private var db = Firestore.firestore()
    private var storage = Storage.storage()
    
    func uploadProfilePicture(userId: String, image: UIImage, completion: @escaping (String?) -> Void) {
        
        // firebase storage accepts image in data format
        guard let imageData = image.jpegData(compressionQuality: 0.75) else {
            completion(nil)
            return
        }
        
        // reference to file in storage
        let storageRef = storage.reference().child("profilePictures/\(userId).jpg")
        
        // uploading image to storage
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("error uploading image to firebase storage: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            // url of uploaded image
            storageRef.downloadURL { url, error in
                if let error = error {
                    print("error getting dowload URL: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                
                if let url = url {
                    completion(url.absoluteString) // converting url to string to return
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    func fetchProfilePicture(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        //image from url
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print ("error fetching image: \(error.localizedDescription)")
                completion(nil)
                return
            }
            if let data = data, let image = UIImage(data: data) {
                completion(image)
            } else {
                completion(nil)
            }
        }.resume()
        
    }
    
    func deleteProfilePicture(userId: String, completion: @escaping (Bool) -> Void) {
        let storageRef = storage.reference().child("profilePictures/\(userId).jpg")
        
        storageRef.delete { error in
            if let error = error {
                print("error deleting image: \(error.localizedDescription)")
                completion(false)
            } else {
                print("profile picture deleted.")
                completion(true)
            }
        }
    }
}

