//
//  PostResult.swift
//  Gauge
//
//  Created by Datta Kansal on 3/6/25.
//

struct PostResult: Identifiable, Codable {
    let id: String
    let userId: String
    let question: String
    let timeAgo: String
    let username: String
    let profilePhoto: String
    let categories: [String]
    let voteCount: Int
}
