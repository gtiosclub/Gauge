//
//  SendFriendRequestView.swift
//  Gauge
//
//  Created by Sahil Ravani on 3/25/25.
//

import SwiftUI

struct SendFriendRequestView: View {
    @ObservedObject var viewModel: FriendsViewModel
    var userId: String

    @State private var searchText = ""
    @State private var searchResults: [User] = []

    var body: some View {
        VStack {
            TextField("Search friends...", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button("Search") {
                Task {
                    if let results = await viewModel.searchFriends(userId: userId, searchString: searchText) {
                        DispatchQueue.main.async {
                            searchResults = results
                        }
                    }
                }
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)

            Divider()
                .padding(.horizontal)

            List(searchResults, id: \.userId) { user in
                FriendSearchResultRow(user: user, viewModel: viewModel, userId: userId)
            }
        }
        .navigationTitle("Add Friends")
    }
}

struct FriendSearchResultRow: View {
    var user: User
    var viewModel: FriendsViewModel
    var userId: String

    @State private var requestSent = false

    var body: some View {
        HStack {
            AsyncImage(url: URL(string: user.profilePhoto ?? "")) { image in
                image.resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
            } placeholder: {
                Circle()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.gray.opacity(0.3))
            }

            VStack(alignment: .leading) {
                Text(user.username)
                    .font(.headline)
            }

            Spacer()

            if requestSent {
                Text("Request Sent")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            } else {
                Button("Request") {
                    Task {
                        do {
                            try await viewModel.sendFriendRequest(from: userId, to: user.userId)
                            DispatchQueue.main.async {
                                requestSent = true
                            }
                        } catch {
                            print("Error sending friend request: \(error.localizedDescription)")
                        }
                    }
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
        .padding()
    }
}

