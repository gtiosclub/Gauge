//
//  SearchResultsView.swift
//  Gauge
//
//  Created by Datta Kansal on 4/10/25.
//
import SwiftUI

struct SearchResultsView: View {
    @EnvironmentObject var userVM: UserFirebase
    @ObservedObject var searchedUserVM: UserFirebase
    @Binding var selectedTab: String
    @Binding var isLoading: Bool
    @Binding var errorMessage: String?
    @Binding var postSearchResults: [PostResult]
    @Binding var userSearchResults: [UserResult]
    @Binding var userSearchProfileImages: [String: UIImage]
    @Binding var navigateToSearchedUser: Bool
    @Binding var searchedUserIsCurrUser: Bool

    var body: some View {
        if isLoading {
            ProgressView("Searching...")
                .padding()
        } else if let errorMessage = errorMessage {
            Text(errorMessage)
                .foregroundStyle(.red)
                .padding()
        } else if (selectedTab == "Topics" && !postSearchResults.isEmpty) {
            List {
                ForEach(postSearchResults) { result in
                    PostResultRow(result: result)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 6, leading: 8, bottom: 6, trailing: 8))
                }
            }
            .listStyle(.plain)
        } else if (selectedTab == "Users" && !userSearchResults.isEmpty) {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(userSearchResults) { user in
                    HStack {
                        ZStack {
                            if let userProfileImage = userSearchProfileImages[user.id] {
                                Image(uiImage: userProfileImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                            } else {
                                Circle()
                                    .fill(Color.gray)
                                    .frame(width: 40, height: 40)
                            }
                        }
                        Text(user.username)
                            .padding(5)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white)
                            .cornerRadius(10)
                    }
                    .onTapGesture {
                        Task {
                            do {
                                let fetchedUser = try await searchedUserVM.getUserData(userId: user.id)
                                await MainActor.run {
                                    searchedUserVM.user = fetchedUser
                                    navigateToSearchedUser = true
                                }
                                try await userVM.updateRecentProfileSearch(with: user.username)
                            } catch {
                                print("Error fetching user data: \(error.localizedDescription)")
                            }
                        }
                    }
                }
            }
            .padding()
        } else {
            Text("No results found.")
                .padding()
        }
    }
}
