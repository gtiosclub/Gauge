//
//  TakeTimeResultsView.swift
//  Gauge
//
//  Created by Datta Kansal on 4/14/25.
//
import SwiftUI
import FirebaseFirestore

struct TakeTimeResultsView: View {
    var user: User
    let myResponses: [String: Int]
    @State private var takes: [Take] = []

    var body: some View {
        List {
            ForEach(myResponses.sorted(by: { $0.key < $1.key }), id: \.key) { id, selectedOption in
                if let take = takes.first(where: { $0.id == id }) {
//                    VStack(alignment: .leading) {
//                        Text(take.question)
//                            .font(.headline)
//                        Text("Your choice: \(selectedOption == 1 ? take.responseOption1 : take.responseOption2)")
//                        .font(.subheadline)
//                        .foregroundColor(.blue)
//                    }
//                    .padding(.vertical, 6)
                    VoteCard(profilePhotoURL: user.profilePhoto, username: user.username, timeAgo: "", tags: [take.topic], vote: (selectedOption == 1 ? take.responseOption1 : take.responseOption2), content: take.question, comments: nil, views: nil, votes: nil)
                }
            }
        }
        .navigationTitle("My TakeTime Results")
        .onAppear {
            fetchTakes()
        }
    }

    func fetchTakes() {
        let ids = Array(myResponses.keys)

        for id in ids {
            Firebase.db.collection("TakeTime").document(id).getDocument { document, error in
                if let document = document,
                   let take = try? document.data(as: Take.self) {
                    DispatchQueue.main.async {
                        takes.append(take)
                    }
                }
            }
        }
    }
}
