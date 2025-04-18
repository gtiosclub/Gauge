import SwiftUI
import Firebase
struct CommentsTabView: View {
    var visitedUser: User
    @State private var comments: [Comment] = []
    @State private var sortOption: String = "Most votes"
    var sortedComments: [Comment] {
        switch sortOption {
        case "Most votes":
            return comments.sorted {
                ($0.likes.count - $0.dislikes.count) > ($1.likes.count - $1.dislikes.count)
            }
        default:
            return comments
        }
    }
    var body: some View {
        VStack(alignment: .leading) {
            // Sorting UI
            HStack {
                Text("Sort by:")
                    .foregroundColor(.gray)
                    .font(.subheadline)
                Menu {
                    Button("Most votes") {
                        sortOption = "Most votes"
                    }
                } label: {
                    HStack {
                        Text(sortOption)
                            .foregroundColor(.black)
                        Image(systemName: "chevron.down")
                            .foregroundColor(.gray)
                    }
                    .padding(6)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
                Spacer()
            }
            .padding(.horizontal)
            // Comment List
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(sortedComments, id: \.commentId) { comment in
                        CommentCard(comment: comment)
                    }
                }
                .padding()
            }
        }
        .onAppear {
            fetchComments()
        }
    }
    func fetchComments() {
        comments = []
        Firebase.db.collection("POSTS").getDocuments { snapshot, error in
            guard let snapshot = snapshot, error == nil else {
                print("Error fetching posts: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            for document in snapshot.documents {
                let postId = document.documentID
                Firebase.db.collection("POSTS").document(postId).collection("COMMENTS")
                    .whereField("userId", isEqualTo: visitedUser.userId)
                    .getDocuments { snapshot, error in
                        guard let snapshot = snapshot, error == nil else {
                            print("Error fetching comments: \(error?.localizedDescription ?? "Unknown error")")
                            return
                        }
                        for doc in snapshot.documents {
                            let data = doc.data()
                            let comment = Comment(
                                commentType: CommentType(rawValue: data["commentType"] as? String ?? "text") ?? .text,
                                postId: postId,
                                userId: data["userId"] as? String ?? "",
                                username: visitedUser.username,
                                profilePhoto: visitedUser.profilePhoto,
                                date: DateConverter.convertStringToDate(data["date"] as? String ?? "") ?? Date(),
                                commentId: doc.documentID,
                                likes: data["likes"] as? [String] ?? [],
                                dislikes: data["dislikes"] as? [String] ?? [],
                                content: data["content"] as? String ?? ""
                            )
                            DispatchQueue.main.async {
                                comments.append(comment)
                            }
                        }
                    }
            }
        }
    }
}

