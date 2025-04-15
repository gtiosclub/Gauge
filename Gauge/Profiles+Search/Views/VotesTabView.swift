//
//  VotesTabView.swift
//  Gauge
//
//  Created by amber verma on 4/14/25.
//

import SwiftUI
import Firebase
struct VotesTabView: View {
    @EnvironmentObject var postVM: PostFirebase
    @EnvironmentObject var userVM: UserFirebase
    var visitedUser: User
    @State private var respondedPosts: [BinaryPost] = []
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(respondedPosts, id: \.postId) { post in
                    if let userResponse = post.responses.first(where: { response in
                        response.userId == visitedUser.userId
                    }) {
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
            Task {
                await fetchRespondedPosts()
            }
        }
    }
    func toggleFavorite(_ post: BinaryPost) {
        if post.favoritedBy.contains(userVM.user.userId) {
            postVM.removeUserFromFavoritedBy(postId: post.postId, userId: userVM.user.userId)
        } else {
            postVM.addUserToFavoritedBy(postId: post.postId, userId: userVM.user.userId)
        }
        // Trigger UI update
        if let index = respondedPosts.firstIndex(where: { $0.postId == post.postId }) {
            if respondedPosts[index].favoritedBy.contains(userVM.user.userId) {
                respondedPosts[index].favoritedBy.removeAll { $0 == userVM.user.userId }
            } else {
                respondedPosts[index].favoritedBy.append(userVM.user.userId)
            }
        }
    }
    func fetchRespondedPosts() async {
        do {
            respondedPosts = []
            let (responseIds, _, _) = try await userVM.getUserPostInteractions(userId: visitedUser.userId, setCurrentUserData: false)
            for id in responseIds {
                let doc = try await Firebase.db.collection("POSTS").document(id).getDocument()
                guard let data = doc.data(),
                      let type = data["type"] as? String,
                      type == PostType.BinaryPost.rawValue else { continue }
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
                // Get responses
                let responseSnap = try await Firebase.db.collection("POSTS").document(id).collection("RESPONSES").getDocuments()
                post.responses = responseSnap.documents.map { d in
                    let data = d.data()
                    return Response(
                        responseId: data["responseId"] as? String ?? UUID().uuidString,
                        userId: data["userId"] as? String ?? "",
                        responseOption: data["responseOption"] as? String ?? ""
                    )
                }
                // Get comments
                let commentSnap = try await Firebase.db.collection("POSTS").document(id).collection("COMMENTS").getDocuments()
                post.comments = commentSnap.documents.map { d in
                    let data = d.data()
                    return Comment(
                        commentType: .text,
                        postId: id,
                        userId: data["userId"] as? String ?? "",
                        username: "",
                        profilePhoto: "",
                        date: DateConverter.convertStringToDate(data["date"] as? String ?? "") ?? Date(),
                        commentId: data["commentId"] as? String ?? UUID().uuidString,
                        likes: data["likes"] as? [String] ?? [],
                        dislikes: data["dislikes"] as? [String] ?? [],
                        content: data["content"] as? String ?? ""
                    )
                }
                // Get views
                let viewSnap = try await Firebase.db.collection("POSTS").document(id).collection("VIEWS").getDocuments()
                post.viewCounter = viewSnap.documents.count
                respondedPosts.append(post)
                respondedPosts.sort { $0.postDateAndTime > $1.postDateAndTime }
            }
        } catch {
            print("❌ Failed to fetch responded posts: \(error.localizedDescription)")
        }
    }
}
