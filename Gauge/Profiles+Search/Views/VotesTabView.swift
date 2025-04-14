//
//  VotesTabView.swift
//  Gauge
//
//  Created by amber verma on 4/14/25.
//

import SwiftUI
import Firebase

struct VotesTabView: View {
//    @EnvironmentObject var postVM: PostFirebase
//    @EnvironmentObject var userVM: UserFirebase
    var visitedUser: User
    @State private var respondedPosts: [BinaryPost] = []

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(respondedPosts, id: \.postId) { post in
                    if let userResponse = post.responses.first(where: { $0.userId == visitedUser.userId }) {
                        VoteCard(
                            profilePhotoURL: visitedUser.profilePhoto,
                            username: visitedUser.username,
                            timeAgo: DateConverter.timeAgo(from: post.postDateAndTime),
                            tags: post.categories.map { $0.rawValue },
                            vote: userResponse.responseOption,
                            content: post.question,
                            comments: post.comments.count,
                            views: post.viewCounter,
                            votes: post.calculateResponses().reduce(0, +)
                        )
                    }
                }
            }
            .padding()
        }
        .onAppear {
            fetchRespondedPosts()
        }
    }

    func fetchRespondedPosts() {
        let ids = visitedUser.myResponses
        respondedPosts = []

        for id in ids {
            Firebase.db.collection("POSTS").document(id).getDocument { doc, error in
                guard let data = doc?.data(), error == nil else {
                    print("Failed to fetch post \(id): \(error?.localizedDescription ?? "Unknown")")
                    return
                }

                if let type = data["type"] as? String, type == PostType.BinaryPost.rawValue {
                    var post = BinaryPost(
                        postId: id,
                        userId: data["userId"] as? String ?? "",
                        categories: Category.mapStringsToCategories(returnedStrings: data["categories"] as? [String] ?? []),
                        topics: data["topics"] as? [String] ?? [],
                        postDateAndTime: (data["postDateAndTime"] as? Timestamp)?.dateValue()
                            ?? DateConverter.convertStringToDate(data["postDateAndTime"] as? String ?? "") ?? Date(),
                        question: data["question"] as? String ?? "",
                        responseOption1: data["responseOption1"] as? String ?? "",
                        responseOption2: data["responseOption2"] as? String ?? "",
                        sublabel1: data["sublabel1"] as? String ?? "",
                        sublabel2: data["sublabel2"] as? String ?? "",
                        favoritedBy: data["favoritedBy"] as? [String] ?? []
                    )

                    post.username = data["username"] as? String ?? "Unknown"
                    post.profilePhoto = data["profilePhoto"] as? String ?? ""

                    let group = DispatchGroup()

                    // Responses
                    group.enter()
                    Firebase.db.collection("POSTS").document(id).collection("RESPONSES").getDocuments { snapshot, _ in
                        if let docs = snapshot?.documents {
                            post.responses = docs.map { d in
                                let d = d.data()
                                return Response(
                                    responseId: d["responseId"] as? String ?? UUID().uuidString,
                                    userId: d["userId"] as? String ?? "",
                                    responseOption: d["responseOption"] as? String ?? ""
                                )
                            }
                        }
                        group.leave()
                    }

                    // Comments
                    group.enter()
                    Firebase.db.collection("POSTS").document(id).collection("COMMENTS").getDocuments { snapshot, _ in
                        if let docs = snapshot?.documents {
                            post.comments = docs.map { d in
                                let d = d.data()
                                return Comment(
                                    commentType: .text,
                                    postId: id,
                                    userId: d["userId"] as? String ?? "",
                                    username: "",
                                    profilePhoto: "",
                                    date: DateConverter.convertStringToDate(d["date"] as? String ?? "") ?? Date(),
                                    commentId: d["commentId"] as? String ?? UUID().uuidString,
                                    likes: d["likes"] as? [String] ?? [],
                                    dislikes: d["dislikes"] as? [String] ?? [],
                                    content: d["content"] as? String ?? ""
                                )
                            }
                        }
                        group.leave()
                    }

                    // Views
                    group.enter()
                    Firebase.db.collection("POSTS").document(id).collection("VIEWS").getDocuments { snapshot, _ in
                        post.viewCounter = snapshot?.documents.count ?? 0
                        group.leave()
                    }

                    group.notify(queue: .main) {
                        respondedPosts.append(post)
                        respondedPosts.sort { $0.postDateAndTime > $1.postDateAndTime }
                    }
                }
            }
        }
    }
}

