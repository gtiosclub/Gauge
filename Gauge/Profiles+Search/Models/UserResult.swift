//
//  UserResult.swift
//  Gauge
//
//  Created by Anthony Le on 3/19/25.
//
import UIKit

struct UserResult: Identifiable {
    let id: String
    let username: String
    let profilePhotoUrl: String
    var profileImage: UIImage?
    
    init(userId: String, username: String, profilePhotoUrl: String) {
        self.id = userId
        self.username = username
        self.profilePhotoUrl = profilePhotoUrl
        self.profileImage = nil
    }
    
    mutating func updateProfileImage(profileImage: UIImage?) {
        self.profileImage = profileImage
    }
}
