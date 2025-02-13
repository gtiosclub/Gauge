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
        @State private var users: [[String: Any]] = []
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
                    List(users.indices, id: \.self) { index in
                        let user = users[index]
                        HStack {
                            Text(user["username"] as? String ?? "Unknown")
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
            
            // Query Firestore for usernames that match the search text
            Firestore.firestore().collection("USERS")
                .whereField("username", isEqualTo: searchText) // Exact match
                .getDocuments { (querySnapshot, error) in
                    isLoading = false
                    if let error = error {
                        print("Error getting documents: \(error)")
                    } else {
                        for document in querySnapshot!.documents {
                            let data = document.data()
                            self.users.append(data)
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

