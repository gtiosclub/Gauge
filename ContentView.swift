//
//  ContentView.swift
//  FriendsView: Search View
//
//  Created by Ajay Desai on 2/8/25.
//

import SwiftUI

struct FriendsView: View {
    var userID: String
    
    var body: some View {
        NavigationView {
            TabView {
                SearchView(userID: userID)
                    .tabItem {
                        
                    }
                
                IncomingRequestsView(userID: userID)
                    .tabItem {
                        
                    }
                
                OutgoingRequestsView(userID: userID)
                    .tabItem {
                        
                    }
                
                ConnectionsView(userID: userID)
                    .tabItem {
                        
                    }
            }
        }
    }
    
    struct SearchView: View {
        var userID: String
        @State private var searchText = ""
        @State private var users: [User] = []
        
        let allUsers: [User] = [
            User(id: "1", username: "Alice"),
            User(id: "2", username: "Bob"),
            User(id: "3", username: "Charlie"),
            User(id: "4", username: "David")
        ]
        
        var body: some View {
            VStack {
                TextField("Search by username", text: $searchText, onCommit: {
                    searchUsers()
                })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                
                List(users) { user in
                    HStack {
                        Text(user.username)
                        Spacer()
                    }
                }
            }
            .padding()
        }
        
        func searchUsers() {
            users = allUsers.filter { $0.username.lowercased().contains(searchText.lowercased()) }
        }
    }

    struct User: Identifiable {
        var id: String
        var username: String
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

/* func searchUsers() {
 let db = Firestore.firestore()
 db.collection("users")
     .whereField("username", isGreaterThanOrEqualTo: searchText)
     .whereField("username", isLessThanOrEqualTo: searchText + "\u{f8ff}")
     .getDocuments { snapshot, error in
         if let error = error {
             print("Error searching users: \(error.localizedDescription)")
             return
         }
         self.users = snapshot?.documents.compactMap { doc in
             try? doc.data(as: User.self)
         } ?? []
     }*/
