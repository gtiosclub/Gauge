//
//  UserResult.swift
//  Gauge
//
//  Created by Anthony Le on 3/19/25.
//

struct UserResult: Identifiable {
    let id: String
    let username: String
    let profilePhotoUrl: String
    var attributes: [String: String] = [:]

    init(userId: String, username: String, profilePhotoUrl: String) {
        self.id = userId
        self.username = username
        self.profilePhotoUrl = profilePhotoUrl
    }
}
