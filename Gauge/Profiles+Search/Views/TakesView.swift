//
//  TakesView.swift
//  Gauge
//
//  Created by amber verma on 3/6/25.
//

import SwiftUI
import Firebase
import FirebaseFirestore
struct TakesView: View {
    @EnvironmentObject var postVM: PostFirebase
    @EnvironmentObject var userVM: UserFirebase
    @State private var selectedPost: BinaryPost?
    @State private var myPosts: [BinaryPost] = []
    @State private var dragAmount: CGSize = .zero
    @State private var optionSelected: Int = 0
    @State private var skipping: Bool = false
    @State private var isConfirmed: Bool = false
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(myPosts, id: \.postId) { post in
                    Button {
                        selectedPost = post
                    } label: {
                        TakeCard(
                            username: userVM.user.username,
                            profilePhotoURL: userVM.user.profilePhoto,
                            timeAgo: DateConverter.timeAgo(from: post.postDateAndTime),
                            tags: post.categories.map { $0.rawValue },
                            content: post.question,
                            votes: post.calculateResponses().reduce(0, +),
                            comments: post.comments.count,
                            views: post.viewCounter
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
        }
        .onAppear {
            fetchMyPosts()
        }
        .sheet(item: $selectedPost, onDismiss: {
            fetchMyPosts()
        }) { post in
            SwipeableTakeSheetView(post: post)
                .presentationDetents([.fraction(0.94)])
                .presentationBackground(Color.white)
        }
    }
    
    func fetchMyPosts() {
        let db = Firestore.firestore()
        myPosts = []
        let postIds = userVM.user.myPosts

        for id in postIds {
            db.collection("POSTS").document(id).getDocument(completion: { doc, error in
                guard let data = doc?.data(), error == nil else {
                    print("❌ Failed to fetch post \(id): \(error?.localizedDescription ?? "Unknown")")
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

                    let group = DispatchGroup()

                    // Fetch responses
                    group.enter()
                    db.collection("POSTS").document(id).collection("RESPONSES").getDocuments { snapshot, error in
                        if let snapshot = snapshot {
                            let responses: [Response] = snapshot.documents.compactMap { doc in
                                let d = doc.data()
                                return Response(
                                    responseId: doc.documentID,
                                    userId: d["userId"] as? String ?? "",
                                    responseOption: d["responseOption"] as? String ?? ""
                                )
                            }
                            post.responses = responses
                        }
                        group.leave()
                    }

                    // Fetch comments
                    group.enter()
                    db.collection("POSTS").document(id).collection("COMMENTS").getDocuments { snapshot, error in
                        if let snapshot = snapshot {
                            let comments: [Comment] = snapshot.documents.compactMap { doc in
                                let d = doc.data()
                                return Comment(
                                    commentType: .text,
                                    postId: id,
                                    userId: d["userId"] as? String ?? "",
                                    username: "",
                                    profilePhoto: "",
                                    date: DateConverter.convertStringToDate(d["date"] as? String ?? "") ?? Date(),
                                    commentId: doc.documentID,
                                    likes: d["likes"] as? [String] ?? [],
                                    dislikes: d["dislikes"] as? [String] ?? [],
                                    content: d["content"] as? String ?? ""
                                )
                            }
                            post.comments = comments
                        }
                        group.leave()
                    }

                    // Fetch views
                    group.enter()
                    db.collection("POSTS").document(id).collection("VIEWS").getDocuments { snapshot, error in
                        if let snapshot = snapshot {
                            post.viewCounter = snapshot.documents.count
                        }
                        group.leave()
                    }

                    group.notify(queue: .main) {
                        myPosts.append(post)
                        myPosts.sort { $0.postDateAndTime > $1.postDateAndTime }
                    }
                }
            })
        }
    }


    
    struct SwipeableSheetWrapper: View {
        @ObservedObject var post: BinaryPost
        @EnvironmentObject var postVM: PostFirebase
        @EnvironmentObject var userVM: UserFirebase
        @State private var dragAmount: CGSize = .zero
        @State private var optionSelected: Int = 0
        @State private var skipping: Bool = false
        @State private var isConfirmed: Bool = false
        var body: some View {
            VStack {
                if isConfirmed || post.responses.contains(where: { $0.userId == userVM.user.userId }) {
                    BinaryFeedResults(
                        post: post,
                        optionSelected: optionSelectedFromResponse()
                    )
                } else {
                    BinaryFeedPost(
                        post: post,
                        dragAmount: $dragAmount,
                        optionSelected: $optionSelected,
                        skipping: $skipping
                    )
                    .onChange(of: optionSelected) { _, newValue in
                        if newValue != 0 {
                            submitResponse(for: newValue)
                        }
                    }
                }
            }
            .padding(.top, 30)
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        private func optionSelectedFromResponse() -> Int {
            if let response = post.responses.first(where: { $0.userId == userVM.user.userId }) {
                return response.responseOption == post.responseOption1 ? 1 : 2
            }
            return 0
        }
        private func submitResponse(for selection: Int) {
            let selectedOption = selection == 1 ? post.responseOption1 : post.responseOption2
            postVM.addResponse(postId: post.postId, userId: userVM.user.userId, responseOption: selectedOption)
            isConfirmed = true
        }
    }
    struct SwipeableSheetView: View {
        @ObservedObject var post: BinaryPost
        @EnvironmentObject var postVM: PostFirebase
        @EnvironmentObject var userVM: UserFirebase
        @State private var dragAmount: CGSize = .zero
        @State private var optionSelected: Int = 0
        @State private var skipping: Bool = false
        @State private var isConfirmed: Bool = false
        var body: some View {
            VStack {
                if isConfirmed || post.responses.contains(where: { $0.userId == userVM.user.userId }) {
                    BinaryFeedResults(post: post, optionSelected: post.responses.first(where: { $0.userId == userVM.user.userId })?.responseOption == post.responseOption1 ? 1 : 2)
                } else {
                    BinaryFeedPost(
                        post: post,
                        dragAmount: $dragAmount,
                        optionSelected: $optionSelected,
                        skipping: $skipping
                    )
                    .onChange(of: optionSelected) { _, newValue in
                        if newValue != 0 {
                            let selectedOption = newValue == 1 ? post.responseOption1 : post.responseOption2
                            postVM.addResponse(postId: post.postId, userId: userVM.user.userId, responseOption: selectedOption)
                            isConfirmed = true
                        }
                    }
                }
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
    }
    struct TakeCard: View {
        var username: String
        var profilePhotoURL: String
        var timeAgo: String
        var tags: [String]
        var content: String
        var votes: Int
        var comments: Int
        var views: Int
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    AsyncImage(url: URL(string: profilePhotoURL)) { image in
                        image.resizable()
                    } placeholder: {
                        Circle().fill(Color(.systemGray3))
                    }
                    .frame(width: 30, height: 30)
                    .clipShape(Circle())
                    Text(username)
                        .font(.system(size: 15, weight: .semibold))
                    Text("• \(timeAgo)")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    Spacer()
                }
                HStack {
                    ForEach(tags, id: \.self) { tag in
                        Text(" \(tag) ")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                    }
                    Spacer()
                }
                Text(content)
                    .font(.system(size: 16))
                    .foregroundColor(.black)
                HStack {
                    Text("\(votes) votes")
                        .foregroundColor(.gray)
                        .font(.subheadline)

                    Spacer()

                    HStack(spacing: 16) {
                        HStack(spacing: 4) {
                            Image(systemName: "bubble.left")
                            Text("\(comments)")
                        }

                        HStack(spacing: 4) {
                            Image(systemName: "eye")
                            Text("\(views)")
                        }

                        Image(systemName: "bookmark")
                        Image(systemName: "square.and.arrow.up")
                    }
                    .foregroundColor(.gray)
                    .font(.subheadline)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
    }
}

