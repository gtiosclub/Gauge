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
    
    func uploadProfilePicture(userId: String, image: UIImage) async -> String? {
        
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
    
    func fetchProfilePicture(from urlString: String) async -> UIImage? {
        
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
    
    func deleteProfilePicture(userId: String) async -> Bool {
        
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
}
