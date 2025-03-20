//
//  UserResult.swift
//  Gauge
//
//  Created by Anthony Le on 3/19/25.
//

struct UserResult: Identifiable {
    let id: String
    let username: String
    let profilePhoto: String

    init(userId: String, username: String, profilePhoto: String) {
        self.id = userId
        self.username = username
        self.profilePhoto = profilePhoto
    }
}
