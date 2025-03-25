//
//  AcceptFriendRequestView.swift
//  Gauge
//
//  Created by Sahil Ravani on 3/25/25.
//

import SwiftUI

struct AcceptFriendRequestView: View {
    @ObservedObject var viewModel: FriendsViewModel
    var userId: String

    @State private var incomingRequests: [String] = []

    var body: some View {
        NavigationView {
            VStack {
                Text("Friend Requests")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding()

                Divider()

                ScrollView {
                    VStack(spacing: 12) {
                        if incomingRequests.isEmpty {
                            Text("No pending friend requests.")
                                .foregroundColor(.gray)
                                .padding()
                        } else {
                            ForEach(incomingRequests, id: \.self) { friendId in
                                FriendRequestRow(
                                    friendId: friendId,
                                    viewModel: viewModel,
                                    onAccept: {
                                        handleAcceptRequest(friendId)
                                    },
                                    onReject: {
                                        handleRejectRequest(friendId)
                                    }
                                )
                            }
                        }
                    }
                    .padding()
                }
            }
            .onAppear {
                fetchIncomingRequests()
            }
        }
    }

    private func fetchIncomingRequests() {
        Task {
            let requests = await viewModel.getIncomingRequests(userId: userId)
            DispatchQueue.main.async {
                incomingRequests = requests.map { $0.userId }
            }
        }
    }

    private func handleAcceptRequest(_ friendId: String) {
        Task {
            do {
                try await viewModel.acceptFriendRequest(friendId: friendId, hostId: userId)
                DispatchQueue.main.async {
                    incomingRequests.removeAll { $0 == friendId }
                }
            } catch {
                print("Error accepting request: \(error.localizedDescription)")
            }
        }
    }

    private func handleRejectRequest(_ friendId: String) {
        Task {
            do {
                try await viewModel.rejectFriendRequest(friendId: friendId, hostId: userId)
                DispatchQueue.main.async {
                    incomingRequests.removeAll { $0 == friendId }
                }
            } catch {
                print("Error rejecting request: \(error.localizedDescription)")
            }
        }
    }
}

struct FriendRequestRow: View {
    let friendId: String
    var viewModel: FriendsViewModel
    var onAccept: () -> Void
    var onReject: () -> Void

    @State private var friendName: String = "Loading..."
    @State private var profileImageUrl: String?

    var body: some View {
        HStack {
            AsyncImage(url: URL(string: profileImageUrl ?? "")) { image in
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
                Text(friendName)
                    .font(.headline)
                Text("Sent you a friend request")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            Spacer()

            Button("Accept", action: onAccept)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)

            Button(action: onReject) {
                Image(systemName: "xmark")
                    .padding()
                    .background(Color.red.opacity(0.7))
                    .foregroundColor(.white)
                    .clipShape(Circle())
            }
        }
        .padding()
        .onAppear {
            Task {
                if let user = await viewModel.getUserFromId(userId: friendId) {
                    DispatchQueue.main.async {
                        self.friendName = user.username
                        self.profileImageUrl = user.profilePhoto
                    }
                }
            }
        }
    }
}

