//
//  RequestsView.swift
//  Gauge
//
//  Created by amber verma on 2/18/25.
//

import SwiftUI

struct RequestsView: View {
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                CustomSearchBar(text: $searchText)
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .frame(height: 36)
                
                Divider()
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 10)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        RequestSection(title: "Today")
                        RequestSection(title: "Last 7 days", count: 2)
                        RequestSection(title: "Last 30 days", count: 3)
                        RequestSection(title: "Older", count: 2)
                    }
                    .padding(.top, 10)
                }
            }
            .navigationBarTitle("Requests", displayMode: .inline)
        }
    }
}

struct RequestSection: View {
    let title: String
    let count: Int
    
    init(title: String, count: Int = 1) {
        self.title = title
        self.count = count
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
                .padding(.horizontal)
                .padding(.bottom, 8)
            
            ForEach(0..<count, id: \.self) { _ in
                FriendRequestView()
                    .padding(.bottom, 10)
            }
        }
    }
}

#Preview {
    RequestsView()
}
