//
//  FriendsView.swift
//  Gauge
//
//  Created by amber verma on 2/18/25.
//

import SwiftUI
struct FriendsView: View {
    @State private var searchText = ""
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: FriendsViewModel
    var currentUser: User
    @State private var showRemoveAlert = false
    @State private var userToRemove: User?
    var filteredFriends: [User] {
        if searchText.isEmpty {
            return viewModel.loadedFriends
        } else {
            return viewModel.loadedFriends.filter {
                $0.username.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    @Sendable
    func loadInitialData() async {
        if let refreshedUser = await viewModel.getUserFromId(userId: currentUser.userId) {
            await MainActor.run {
                viewModel.friends = refreshedUser.friends
                viewModel.incomingRequests = refreshedUser.friendIn
                viewModel.outgoingRequests = refreshedUser.friendOut
            }
            await viewModel.fetchFriendsDetails()
            await viewModel.fetchIncomingRequestDetails(userId: currentUser.userId)
        }
    }
    var body: some View {
            VStack(spacing: 0) {
                CustomSearchBar(text: $searchText)
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .frame(height: 36)
                Divider()
                    .padding(.horizontal)
                    .padding(.top, 8)
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        if !viewModel.loadedRequests.isEmpty {
                            SectionHeader(title: "Requests")
                                .padding(.top, 16)
                            ForEach(viewModel.loadedRequests.prefix(2)) { user in
                                RequestRow(user: user, viewModel: viewModel, currentUser: currentUser)
                            }
                           
                            NavigationLink(destination: RequestsView(viewModel: viewModel, currentUser: currentUser)) {
                                MoreRequestsView(requests: viewModel.loadedRequests)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    
                        if !filteredFriends.isEmpty {
                            SectionHeader(title: "\(filteredFriends.count) Friends")
                                .padding(.top, 16)
                        }
                        if filteredFriends.isEmpty {
                            EmptyFriendsView(searchText: searchText)
                        } else {
                            ForEach(filteredFriends) { friend in
                                HStack(spacing: 10) {
                                    AsyncImage(url: URL(string: friend.profilePhoto)) { image in
                                        image.resizable()
                                    } placeholder: {
                                        Circle().fill(Color(.systemGray3))
                                    }
                                    .frame(width: 30, height: 30)
                                    .clipShape(Circle())
                                    Text(friend.username)
                                    Spacer()
                                    Button(action: {
                                        userToRemove = friend
                                        showRemoveAlert = true
                                    }) {
                                        Image(systemName: "xmark")
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .navigationBarTitle("Friends", displayMode: .inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Profile")
                        }
                    }
                }
            }

            .confirmationDialog("Remove this friend?", isPresented: $showRemoveAlert, titleVisibility: .visible) {
                Button("Remove", role: .destructive) {
                    if let user = userToRemove {
                        removeFriend(user)
                    }
                }
                Button("Cancel", role: .cancel) {}
            }
        .task {
            await loadInitialData()
        }
        .refreshable {
            await loadInitialData()
        }
    }
    func refreshData() {
        Task {
            await loadInitialData()
        }
    }
    func removeFriend(_ friend: User) {
        Task {
            do {
                try await viewModel.removeFriend(friendId: friend.userId, hostId: currentUser.userId)
                await viewModel.fetchFriendsDetails()
            } catch {
                print("Error removing friend: \(error)")
            }
        }
    }
}
struct RequestRow: View {
    let user: User
    @ObservedObject var viewModel: FriendsViewModel
    let currentUser: User
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
            Button("Accept") {
                handleAccept()
            }
            .buttonStyle(AcceptButtonStyle())
            Button(action: handleReject) {
                Image(systemName: "xmark")
                    .buttonStyle(RejectButtonStyle())
            }
        }
        .padding(.horizontal)
    }
    private func handleAccept() {
        Task {
            try? await viewModel.acceptFriendRequest(
                friendId: user.userId,
                hostId: currentUser.userId
            )
            await viewModel.fetchIncomingRequestDetails(userId: currentUser.userId)
            await viewModel.fetchFriendsDetails()
        }
    }
    private func handleReject() {
        Task {
            try? await viewModel.rejectFriendRequest(
                friendId: user.userId,
                hostId: currentUser.userId
            )
            await viewModel.fetchIncomingRequestDetails(userId: currentUser.userId)
        }
    }
}
struct MoreRequestsView: View {
    let requests: [User]
    var body: some View {
        HStack {
            HStack(spacing: -10) {
                ForEach(Array(requests.prefix(4)), id: \.id) { user in
                    ProfileImagePill(profilePhoto: user.profilePhoto)
                }
            }
            let othersCount = requests.count - 2
            if othersCount > 0 {
                Text("and \(othersCount) others...")
                    .font(.subheadline)
                    .foregroundColor(.black)
                    .padding(.leading, 6)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding(.horizontal)
        .padding(.top, -4)
    }
}
struct ProfileImagePill: View {
    let profilePhoto: String
    var body: some View {
        Group {
            if let url = URL(string: profilePhoto), !profilePhoto.isEmpty {
                AsyncImage(url: url) { image in
                    image.resizable()
                } placeholder: {
                    Circle().fill(Color(.systemGray3))
                }
            } else {
                Circle().fill(Color(.systemGray3))
            }
        }
        .frame(width: 28, height: 28)
        .clipShape(Circle())
        .overlay(Circle().stroke(Color.white, lineWidth: 1))
        .shadow(radius: 1)
    }
}
struct SectionHeader: View {
    var title: String
    var body: some View {
        Text(title)
            .font(.headline)
            .fontWeight(.semibold)
            .padding(.horizontal)
    }
}
struct EmptyFriendsView: View {
    let searchText: String
    var body: some View {
        VStack {
            Spacer()
            Text(searchText.isEmpty ? "No friends added yet" : "No matching friends")
                .foregroundColor(.gray)
            Spacer()
        }
        .frame(height: 200)
    }
}
struct AcceptButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .bold))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(6)
            .opacity(configuration.isPressed ? 0.7 : 1.0)
    }
}
struct RejectButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: 20, height: 15)
            .padding(6)
            .foregroundColor(.gray)
            .background(Color.gray.opacity(0.3))
            .cornerRadius(4)
            .opacity(configuration.isPressed ? 0.7 : 1.0)
    }
}
