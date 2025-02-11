//
//  FriendsView.swift
//  Gauge
//
//  Created by amber verma on 2/6/25.
//

import SwiftUI
import FirebaseFirestore


struct FriendsView: View {
    var userID: String
    
    var body: some View {
        NavigationView {
            TabView {
                SearchView(userID: userID)
                    .tabItem {
                        Image(systemName: "magnifyingglass")
                        Text("Search")
                    }
                
                IncomingRequestsView(userID: userID)
                    .tabItem {
                        Image(systemName: "envelope.fill")
                        Text("Incoming")
                    }
                
                OutgoingRequestsView(userID: userID)
                    .tabItem {
                        Image(systemName: "paperplane.fill")
                        Text("Outgoing")
                    }
                
                ConnectionsView(userID: userID)
                    .tabItem {
                        Image(systemName: "person.2.fill")
                        Text("Connections")
                    }
            }
            .navigationTitle("Friends")
        }
    }
    
    struct SearchView: View {
        var userID: String
        @State private var searchText = ""
        @State private var users: [User] = []
        @State private var isLoading = false
        
        var body: some View {
            VStack {
                // Search Bar
                TextField("Search by username", text: $searchText, onCommit: {
                    searchUsers()
                })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                
                // Loading Indicator or List of Users
                if isLoading {
                    ProgressView("Searching...")
                        .padding()
                } else {
                    List(users) { user in
                        HStack {
                            Text(user.username)
                            Spacer()
                            Button(action: {
                                // Add friend request logic here
                            }) {
                                Text("Add Friend")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .padding()
            .navigationTitle("Search Friends")
        }
        
        func searchUsers() {
            isLoading = true
            users.removeAll()
            
            // Use the Firebase singleton instance to query Firestore
            Firebase.db.collection("USERS")
                .whereField("username", isGreaterThanOrEqualTo: searchText)
                .whereField("username", isLessThanOrEqualTo: searchText + "\u{f8ff}")
                .getDocuments { (querySnapshot, error) in
                    isLoading = false
                    if let error = error {
                        print("Error getting documents: \(error)")
                    } else {
                        for document in querySnapshot!.documents {
                            let data = document.data()
                            if let userID = data["userID"] as? String, let username = data["username"] as? String, let email = data["email"] as? String {
                                let user = User(userId: userID, username: username,email:email)
                                self.users.append(user)
                            }
                        }
                    }
                }
        }
    }
    
    struct IncomingRequestsView: View {
        var userID: String
        
        var body: some View {
            VStack {
                Text("Incoming Friend Requests")
                    .font(.headline)
                Spacer()
            }
            .padding()
        }
    }
    
    struct OutgoingRequestsView: View {
        var userID: String
        
        var body: some View {
            VStack {
                Text("Outgoing Friend Requests")
                    .font(.headline)
                Spacer()
            }
            .padding()
        }
    }
    
    struct ConnectionsView: View {
        var userID: String
        
        var body: some View {
            VStack {
                Text("Your Connections (Friends)")
                    .font(.headline)
                Spacer()
            }
            .padding()
        }
    }
}

