//
//  ProfileVisitView.swift
//  Gauge
//
//  Created by Datta Kansal on 4/14/25.
//

import SwiftUI
import Firebase

struct ProfileVisitView: View {
    let user: User

    @State private var selectedTab: String = "Takes"
    @State private var selectedBadge: BadgeModel? = nil
    @State private var showingTakeTimeResults = false
    @State private var isSendingRequest: Bool = false
    @StateObject private var profileVM = ProfileViewModel()
    
    let tabs = ["Takes", "Votes", "Comments", "Badges", "Statistics", "Favorites"]

    let userTags = ["📏5'9", "📍New York", "🔒Single", "🎓Alumni"]
    
    @ObservedObject var friendsViewModel: FriendsViewModel

    enum FriendStatus {
        case none, pending, friends
    }
        
    var currentFriendStatus: FriendStatus {
        if friendsViewModel.friends.contains(user.userId) {
            return .friends
        } else if friendsViewModel.outgoingRequests.contains(user.userId) {
            return .pending
        } else {
            return .none
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    HStack(alignment: .center) {
                        ZStack {
                            if let emoji = user.attributes["profileEmoji"], !emoji.isEmpty {
                                Text(emoji)
                                    .font(.system(size: 60))
                            } else if let url = URL(string: user.profilePhoto),
                                      !user.profilePhoto.isEmpty {
                                AsyncImage(url: url) { phase in
                                    if let image = phase.image {
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 80, height: 80)
                                            .clipShape(Circle())
                                    } else if phase.error != nil {
                                        Circle()
                                            .fill(Color.gray)
                                            .frame(width: 80, height: 80)
                                    } else {
                                        ProgressView()
                                            .frame(width: 80, height: 80)
                                    }
                                }
                            } else {
                                Circle()
                                    .frame(width: 80, height: 80)
                                    .foregroundColor(.gray)
                            }
                            
                            // TakeTime overlay button.
                            Button(action: {
                                showingTakeTimeResults = true
                            }) {
                                Circle()
                                    .foregroundColor(Color.black.opacity(0))
                                    .frame(width: 80, height: 80)
                                    .overlay(
                                        Circle()
                                            .stroke(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [.blue, .purple]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 3
                                            )
                                            .opacity(user.myTakeTime.isEmpty ? 0 : 1)
                                    )
                            }
                            .disabled(user.myTakeTime.isEmpty)
                        }
                        
                        VStack(alignment: .leading) {
                            Text(user.username)
                                .font(.system(size: 26))
                                .fontWeight(.medium)
                        HStack {
                             if currentFriendStatus == .none {
                                 Button(action: {
                                     Task {
                                         isSendingRequest = true
                                         do {
                                             try await friendsViewModel.sendFriendRequest(to: user)
                                         } catch {
                                             print("Error sending friend request: \(error)")
                                         }
                                         isSendingRequest = false
                                     }
                                 }) {
                                     if isSendingRequest {
                                         ProgressView()
                                             .progressViewStyle(CircularProgressViewStyle())
                                     } else {
                                         Text("+ Add Friend")
                                             .font(.subheadline)
                                             .foregroundColor(.blue)
                                     }
                                 }
                             } else if currentFriendStatus == .pending {
                                 Text("Friend Request Sent")
                                     .font(.subheadline)
                                     .foregroundColor(.gray)
                             } else if currentFriendStatus == .friends {
                                 Text("Friends")
                                     .font(.subheadline)
                                     .foregroundColor(.green)
                             }
                             Spacer()
                             HStack(spacing: 4) {
                                 Image(systemName: "person.2.fill")
                                     .font(.headline)
                                 Text("\(user.friends.count)")
                                     .font(.headline)
                             }
                             .foregroundColor(.gray)
                         }
                     }
                     .padding(.leading, 8)
                     Spacer()
                 }
                 .padding(.horizontal, 16)
                 .padding(.top, 15)
                    
                    HStack {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(userTags, id: \.self) { tag in
                                    Text(tag)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .font(.system(size: 14))
                                        .background(Color.gray.opacity(0.2))
                                        .foregroundColor(.black)
                                        .cornerRadius(15)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    
                    HStack {
                        Text("A short bio that describes this user")
                            .padding(.horizontal, 16)
                        Spacer()
                    }
                    
                    VStack(spacing: 0) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(tabs, id: \.self) { tab in
                                    TabButton(title: tab, selectedTab: $selectedTab)
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                        .padding(.top, 5)
                        
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(Color(.systemGray))
                            .ignoresSafeArea(.container, edges: .horizontal)
                    }
                    
                    
                    Group {
                        if selectedTab == "Badges" {
                            BadgesView(onBadgeTap: { badge in
                                selectedBadge = badge
                            })
                        } else if selectedTab == "Votes" {
                            VoteCardsView()
                        } else if selectedTab == "Takes" {
                            TakesView(visitedUser: user, profileVM: profileVM)
                        } else if selectedTab == "Statistics" {
                            VStack(alignment: .leading, spacing: 0) {
                                Text("Username Statistics")
                                    .font(.system(size:21))
                                    .fontWeight(.bold)
                                    .padding(.vertical, 20)
                                    .padding(.horizontal)
                                    .frame(maxWidth: .infinity, alignment: .center)

                                VStack(spacing: 0) {
                                    // Total Votes Made
                                    HStack {
                                        Text("Total Votes Made")
                                            .font(.system(size: 17))
                                            .fontWeight(.regular)
                                        Spacer()
                                        HStack {
                                            Text("100 Votes")
                                                .font(.system(size: 17))
                                                .foregroundColor(.gray)
                                            Image(systemName: "chevron.right")
                                                .foregroundColor(.gray)
                                                .font(.system(size: 14))
                                        }
                                    }
                                    .padding(.vertical, 15)
                                    .padding(.horizontal)

                                    Divider().padding(.horizontal)

                                    // Total Takes Made
                                    HStack {
                                        Text("Total Takes Made")
                                            .font(.system(size: 17))
                                            .fontWeight(.regular)
                                        Spacer()
                                        HStack {
                                            Text("25 Takes")
                                                .font(.system(size: 17))
                                                .foregroundColor(.gray)
                                            Image(systemName: "chevron.right")
                                                .foregroundColor(.gray)
                                                .font(.system(size: 14))
                                        }
                                    }
                                    .padding(.vertical, 15)
                                    .padding(.horizontal)

                                    Divider().padding(.horizontal)

                                    // Total Votes Collected
                                    HStack {
                                        Text("Total Votes Collected")
                                            .font(.system(size: 17))
                                            .fontWeight(.regular)
                                        Spacer()
                                        HStack {
                                            Text("275 Votes")
                                                .font(.system(size: 17))
                                                .foregroundColor(.gray)
                                            Image(systemName: "chevron.right")
                                                .foregroundColor(.gray)
                                                .font(.system(size: 14))
                                        }
                                    }
                                    .padding(.vertical, 15)
                                    .padding(.horizontal)

                                    Divider().padding(.horizontal)

                                    HStack {
                                        Text("Total Comments Made")
                                            .font(.system(size: 17))
                                            .fontWeight(.regular)
                                        Spacer()
                                        HStack {
                                            Text("110 Comments")
                                                .font(.system(size: 17))
                                                .foregroundColor(.gray)
                                            Image(systemName: "chevron.right")
                                                .foregroundColor(.gray)
                                                .font(.system(size: 14))
                                        }
                                    }
                                    .padding(.vertical, 15)
                                    .padding(.horizontal)

                                    Divider().padding(.horizontal)

                                    HStack {
                                        Text("Ratio View/Response")
                                            .font(.system(size: 17))
                                            .fontWeight(.regular)
                                        Spacer()
                                        HStack {
                                            Text("0.75")
                                                .font(.system(size: 17))
                                                .foregroundColor(.gray)
                                            Image(systemName: "chevron.right")
                                                .foregroundColor(.gray)
                                                .font(.system(size: 14))
                                        }
                                    }
                                    .padding(.vertical, 15)
                                    .padding(.horizontal)
                                }
                                Spacer()
                            }
                            .background(Color.white)
                            .cornerRadius(10)
                            .padding([.horizontal, .bottom])
                        }  else if selectedTab == "Comments" {
                            Text("Comments Content")
                                .padding()
                        } else if selectedTab == "Favorites" {
                            Text("Favorites Content")
                                .padding()
                        } else {
                            Text("\(selectedTab) Content Here")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(10)
                                .padding()
                        }
                    }
                }
            }
            .sheet(isPresented: $showingTakeTimeResults) {
                TakeTimeResultsView(myResponses: user.myTakeTime)
            }
        }
    }
}
