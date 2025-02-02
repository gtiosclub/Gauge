//
//  Post.swift
//  Gauge
//
//  Created by Austin Huguenard on 2/2/25.
//

import Foundation

protocol Post {
    var postId: String {get set}
    var userId: String {get set}
    var comments: [String] {get set}
    var category: Category {get set} // (String Firebase)
    var viewCounter: Int {get set}
    var responseCounter: Int {get set}
    var postDateAndTime: Date {get set} // (String Firebase)
}

enum Category {
    case food, fashion, travel, sports, entertainment, tech, arts, other
}

struct Comment {
    var commentType: String
    var userId: String
    var commentId: String
    var likeCount: Int
    var dislikeCount: Int
}
