//
//  PostResultRow.swift
//  Gauge
//
//  Created by Datta Kansal on 3/6/25.
//

import SwiftUI

// Custom Shape that rounds only specified corners.
struct RoundedCorners: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

struct PostResultRow: View {
    let result: PostResult
    @EnvironmentObject var userVM: UserFirebase

    private static var userCache: [String: (username: String, profilePhoto: String)] = [:]
    @State private var posterData: (username: String, profilePhoto: String)? = nil

    @State private var friendInteractors: [String] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Group {
                    if let data = posterData,
                       !data.profilePhoto.isEmpty,
                       let url = URL(string: data.profilePhoto) {
                        AsyncImage(url: url) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 20, height: 20)
                                    .clipShape(Circle())
                            } else if phase.error != nil {
                                Circle()
                                    .fill(Color.gray)
                                    .frame(width: 20, height: 20)
                            } else {
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 20, height: 20)
                            }
                        }
                    } else if let url = URL(string: result.profilePhoto), !result.profilePhoto.isEmpty {
                        AsyncImage(url: url) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 20, height: 20)
                                    .clipShape(Circle())
                            } else if phase.error != nil {
                                Circle()
                                    .fill(Color.gray)
                                    .frame(width: 20, height: 20)
                            } else {
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 20, height: 20)
                            }
                        }
                    } else {
                        Circle()
                            .fill(Color.gray)
                            .frame(width: 20, height: 20)
                    }
                }

                Text(posterData?.username ?? result.username)
                    .font(.system(size: 16, weight: .regular))
                Text("·")
                    .font(.system(size: 16, weight: .regular))
                Text("\(result.timeAgo) ago")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.black)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 32)

            if !result.categories.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(result.categories, id: \.self) { cat in
                            Text(cat)
                                .font(.system(size: 14, weight: .regular))
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                                .background(Color(.systemGray5))
                                .clipShape(Capsule())
                        }
                    }
                    .padding(.horizontal)
                }
            }

            Text(result.question)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.primary)
                .lineSpacing(4)
                .padding(.horizontal)
            
            HStack {
                Text("\(result.voteCount) votes")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.black)
                Spacer()
                if !friendInteractors.isEmpty {
                    HStack(spacing: -8) {
                        ForEach(friendInteractors, id: \.self) { friendId in
                            Group {
                                if let friendData = userVM.useridsToPhotosAndUsernames[friendId],
                                   !friendData.photoURL.isEmpty,
                                   let url = URL(string: friendData.photoURL) {
                                    AsyncImage(url: url) { phase in
                                        if let image = phase.image {
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 20, height: 20)
                                                .clipShape(Circle())
                                        } else if phase.error != nil {
                                            Circle()
                                                .fill(Color.gray)
                                                .frame(width: 20, height: 20)
                                        } else {
                                            Circle()
                                                .fill(Color.gray.opacity(0.3))
                                                .frame(width: 20, height: 20)
                                        }
                                    }
                                } else {
                                    Circle()
                                        .fill(Color.gray)
                                        .frame(width: 20, height: 20)
                                        .task {
                                            do {
                                                try await userVM.populateUsernameAndProfilePhoto(userId: friendId)
                                            } catch {
                                                print("Error preloading friend \(friendId): \(error.localizedDescription)")
                                            }
                                        }
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 32)
        }
        .frame(maxWidth: .infinity)
        .background(
            RoundedCorners(radius: 12, corners: [.topLeft, .topRight])
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
        )
        .edgesIgnoringSafeArea(.horizontal)
        .padding(.vertical, -12)
        .onAppear {
            if let cached = Self.userCache[result.userId] {
                posterData = cached
            } else {
                Task {
                    do {
                        let fetchedUser = try await userVM.getUserData(userId: result.userId)
                        let newData = (username: fetchedUser.username, profilePhoto: fetchedUser.profilePhoto)
                        await MainActor.run {
                            Self.userCache[result.userId] = newData
                            posterData = newData
                        }
                    } catch {
                        print("Error fetching poster data: \(error.localizedDescription)")
                    }
                }
            }

            Task {
                do {
                    let interactors = try await SearchViewModel().getFriendInteractors(for: result.id, myFriends: userVM.user.friends)
                    await MainActor.run {
                        friendInteractors = interactors
                    }
                } catch {
                    print("Error fetching friend interactions: \(error.localizedDescription)")
                }
            }
        }
    }
}
