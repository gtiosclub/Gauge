//
//  RequestsView.swift
//  Gauge
//
//  Created by amber verma on 2/18/25.
//

import SwiftUI
struct RequestsView: View {
    @State private var searchText = ""
    @ObservedObject var viewModel: FriendsViewModel
    var currentUser: User
    @State private var isLoading: Bool = true
    @State private var incomingRequests: [User] = []
    @Environment(\.dismiss) var dismiss
    var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    CustomSearchBar(text: $searchText)
                        .padding(.horizontal)
                        .padding(.top, 12)
                    Divider()
                        .padding(.horizontal)
                    if isLoading {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                        .padding(.top, 32)
                    } else if filteredRequests.isEmpty {
                        Text("No requests found.")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 80)
                    } else {
                        let groups = groupRequestsByDate(filteredRequests)
                        ForEach(groups, id: \.title) { group in
                            RequestSection(
                                title: group.title,
                                users: group.users,
                                onAccept: { user in
                                    Task {
                                        try? await viewModel.acceptFriendRequest(
                                            friendId: user.userId,
                                            hostId: currentUser.userId
                                        )
                                        await loadRequests()
                                    }
                                },
                                onReject: { user in
                                    Task {
                                        try? await viewModel.rejectFriendRequest(
                                            friendId: user.userId,
                                            hostId: currentUser.userId
                                        )
                                        await loadRequests()
                                    }
                                }
                            )
                            .padding(.horizontal)
                            .padding(.top, 8)
                        }
                    }
                }
                .padding(.bottom, 20)
            }
            .navigationBarTitle("Requests", displayMode: .inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Friends")
                        }
                    }
                }
            }

        .task {
            await loadRequests()
        }
    }
    var filteredRequests: [User] {
        searchText.isEmpty
            ? incomingRequests
            : incomingRequests.filter {
                $0.username.lowercased().contains(searchText.lowercased())
            }
    }
    func loadRequests() async {
        isLoading = true
        incomingRequests = await viewModel.getIncomingRequests(userId: currentUser.userId)
        isLoading = false
    }
    func groupRequestsByDate(_ users: [User]) -> [(title: String, users: [User])] {
        let now = Date()
        var today: [User] = []
        var last7Days: [User] = []
        var earlier: [User] = []
        for user in users {
            let diff = Calendar.current.dateComponents([.day], from: user.lastLogin, to: now).day ?? 999
            if diff == 0 {
                today.append(user)
            } else if diff <= 7 {
                last7Days.append(user)
            } else {
                earlier.append(user)
            }
        }
        var groups: [(title: String, users: [User])] = []
        if !today.isEmpty { groups.append(("Today", today)) }
        if !last7Days.isEmpty { groups.append(("Last 7 Days", last7Days)) }
        if !earlier.isEmpty { groups.append(("Earlier", earlier)) }
        return groups
    }
}
struct RequestSection: View {
    let title: String
    let users: [User]
    let onAccept: (User) -> Void
    let onReject: (User) -> Void
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
                .padding(.horizontal)
            ForEach(users) { user in
                FriendRequestView(user: user, accept: {
                    onAccept(user)
                }, reject: {
                    onReject(user)
                })
            }
        }
    }
}
struct FriendRequestView: View {
    let user: User
    let accept: () -> Void
    let reject: () -> Void
    var body: some View {
        HStack(spacing: 10) {
            AsyncImage(url: URL(string: user.profilePhoto)) { image in
                image.resizable()
            } placeholder: {
                Circle().fill(Color(.systemGray3))
            }
            .frame(width: 30, height: 30)
            .clipShape(Circle())
            Text(user.username)
            Spacer()
            Button("Accept", action: accept)
                .font(.system(size: 14, weight: .bold))
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(6)
            Button(action: reject) {
                Image(systemName: "xmark")
                    .frame(width: 20, height: 15)
                    .padding(6)
                    .foregroundColor(.gray)
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(4)
            }
        }
        .padding(.horizontal)
    }
}
