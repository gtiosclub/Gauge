//
//  RecentSearchesView.swift
//  Gauge
//
//  Created by Datta Kansal on 4/10/25.
//
import SwiftUI

struct RecentSearchesView: View {
    @EnvironmentObject var userVM: UserFirebase
    @FocusState.Binding var isSearchFieldFocused: Bool
    @Binding var searchText: String
    @Binding var selectedTab: String
    
    @State private var isUpdating: Bool = false
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                Text("Recent")
                    .font(.headline)
                    .padding(.leading)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        let recentSearches: [String] = {
                            if selectedTab == "Topics" {
                                return Array(userVM.user.myPostSearches.prefix(5))
                            } else {
                                return Array(userVM.user.myProfileSearches.prefix(5))
                            }
                        }()
                        
                        ForEach(Array(recentSearches.enumerated()), id: \.element) { index, search in
                            HStack {
                                if selectedTab == "Topics" {
                                    Image(systemName: "magnifyingglass")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.black)
                                        .padding(8)
                                        .background(Color(.systemGray5))
                                        .clipShape(Circle())
                                } else {
                                    Image(systemName: "person")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.black)
                                        .padding(8)
                                        .background(Color(.systemGray5))
                                        .clipShape(Circle())
                                }
                                
                                Text(search)
                                    .padding(5)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.white)
                                    .cornerRadius(10)
                                
                                Button {
                                    Task {
                                        isUpdating = true
                                        do {
                                            if selectedTab == "Topics" {
                                                try await userVM.deleteRecentPostSearch(search)
                                            } else {
                                                try await userVM.deleteRecentProfileSearch(search)
                                            }
                                        } catch {
                                            print("Error deleting recent search: \(error.localizedDescription)")
                                        }
                                        isUpdating = false
                                    }
                                } label: {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 12, weight: .regular))
                                        .foregroundColor(Color(.systemGray))
                                        .padding()
                                }
                            }
                            .onTapGesture {
                                searchText = search
                                Task {
                                    isUpdating = true
                                    do {
                                        if selectedTab == "Topics" {
                                            try await userVM.updateRecentPostSearch(with: search)
                                        } else {
                                            try await userVM.updateRecentProfileSearch(with: search)
                                        }
                                    } catch {
                                        print("Error updating recent search: \(error.localizedDescription)")
                                    }
                                    isUpdating = false
                                }
                            }
                        }
                    }
                    .padding()
                }
                
                HStack {
                    Picker(selection: $selectedTab, label: Text("")) {
                        ForEach(["Topics", "Users"], id: \.self) { tab in
                            Text(tab).tag(tab)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(width: 300)
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
            
            if isUpdating {
                ZStack {
                    Color.black.opacity(0.25).ignoresSafeArea()
                    ProgressView("Updating...")
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                }
            }
        }
    }
}
