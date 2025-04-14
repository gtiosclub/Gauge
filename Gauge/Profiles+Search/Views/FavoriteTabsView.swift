//
//  FavoriteTabsView.swift
//  Gauge
//
//  Created by amber verma on 4/14/25.
//

import SwiftUI
import FirebaseFirestore

struct FavoritesTabView: View {
    @EnvironmentObject var userVM: UserFirebase
    var visitedUser: User
//    @EnvironmentObject var postVM: PostFirebase
    @State private var favoritedPosts: [BinaryPost] = []

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(favoritedPosts, id: \.postId) { post in
                    FavoriteCard(post: post, onUnfavorite: {
                        favoritedPosts.removeAll { $0.postId == post.postId }
                    })
                }
            }
            .padding()
        }
        .onAppear {
            fetchFavorites()
        }
    }

    private func fetchFavorites() {
        Task {
            do {
                let favoriteIDs = try await userVM.getUserFavorites(userId: visitedUser.userId)
                favoritedPosts = []

                for id in favoriteIDs {
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

                    try await userVM.populateUsernameAndProfilePhoto(userId: post.userId)
                    if let patch = userVM.useridsToPhotosAndUsernames[post.userId] {
                        post.username = patch.username
                        post.profilePhoto = patch.photoURL
                    }

                    let group = DispatchGroup()

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

                    group.enter()
                    Firebase.db.collection("POSTS").document(id).collection("VIEWS").getDocuments { snapshot, _ in
                        post.viewCounter = snapshot?.documents.count ?? 0
                        group.leave()
                    }

                    group.notify(queue: .main) {
                        favoritedPosts.append(post)
                        favoritedPosts.sort { $0.postDateAndTime > $1.postDateAndTime }
                    }
                }
            } catch {
                print("❌ Failed to fetch favorites: \(error.localizedDescription)")
            }
        }
    }
}
