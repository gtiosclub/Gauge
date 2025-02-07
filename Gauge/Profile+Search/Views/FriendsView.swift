//
//  FriendsView.swift
//  Gauge
//
//  Created by amber verma on 2/6/25.
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
        
        var body: some View {
            VStack {
                Text("Search for friends")
                    .font(.headline)
                Spacer()
            }
            .padding()
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
