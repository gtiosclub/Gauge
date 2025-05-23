//
//  Post.swift
//  Gauge
//
//  Created by Austin Huguenard on 2/2/25.
//

import Foundation

protocol Post: ObservableObject, Identifiable {
    var postId: String {get set}
    var userId: String {get set}
    var username: String {get set}
    var profilePhoto: String {get set}
    var comments: [Comment] {get set}
    var responses: [Response] {get set}
    var topics: [String] {get set}
    var categories: [Category] {get set} // String in Firebase
    var viewCounter: Int {get set}
    var postDateAndTime: Date {get set} // String in Firebase
    var favoritedBy: [String] {get set} // UserIds of users that have favorited
    var question: String {get set}
    func calculateResponses() -> [Int]
}

enum PostWrapper: Identifiable {
    case binary(BinaryPost)
    case slider(SliderPost)
    
    var id: String {
        switch self {
        case .binary(let post):
            return post.postId
        case .slider(let post):
            return post.postId
        }
    }
}

//class AnyObservablePost: ObservableObject, Identifiable {
//    let postId: String
//    let wrappedPost: any Post
//    
//
//    init(_ post: any Post) {
//        self.postId = post.postId
//        self.wrappedPost = post
//    }
//}

enum PostType: String {
    case BinaryPost, SliderPost, RankPost
}

struct Comment: Identifiable, Hashable {
    var id: String {commentId}
    var commentType: CommentType // enum (text, GIF), String in Firebase
    var postId: String // NOT stored in Firebase
    var userId: String
    var username: String = "" // NOT stored in Firebase
    var profilePhoto: String = "" // NOT stored in Firebase
    var date: Date
    var commentId: String // The document ID in firebase
    var likes: [String] // userIds
    var dislikes: [String] // userIds
    var content: String
}

enum CommentType:String,CaseIterable {
    case text = "text"
    case GIF = "GIF"
}

struct Response {
    var responseId: String
    var userId: String
    var responseOption: String
}
