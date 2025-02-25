//
//  ProfileView.swift
//  Gauge
//
//  Created by Sahil Ravani on 2/16/25.
//

import SwiftUI

struct ProfileView: View {
    @State private var selectedTab: String = "Takes"

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Circle()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.gray)

                    VStack(alignment: .leading) {
                        Text("username")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Button(action: {
                        }) {
                            Text("Edit Profile")
                                .font(.caption)
                                .padding(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.black, lineWidth: 1)
                                )
                        }
                    }
                    Spacer()
                }
                .padding()

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        TabButton(title: "Takes", selectedTab: $selectedTab)
                        Spacer()
                        TabButton(title: "Votes", selectedTab: $selectedTab)
                        Spacer()
                        TabButton(title: "Comments", selectedTab: $selectedTab)
                        Spacer()
                        TabButton(title: "Badges", selectedTab: $selectedTab)
                        Spacer()
                        TabButton(title: "Statistics", selectedTab: $selectedTab)
                        Spacer()
                        TabButton(title: "Favorites", selectedTab: $selectedTab)
                    }
                    .padding(.horizontal)
                }
                .padding(.top, 10)
                VStack {
                    Text("\(selectedTab) Content Here")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(UIColor.systemGray6))
                }
                .cornerRadius(10)
                .padding()

                Spacer()
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape")
                            .foregroundColor(.black)
                    }
                }
            }
        }
    }
}

struct TabButton: View {
    let title: String
    @Binding var selectedTab: String

    var body: some View {
        Button(action: {
            selectedTab = title
        }) {
            VStack(spacing: 0) {
                Text(title)
                    .font(.system(size: 25))
                    .foregroundColor(selectedTab == title ? .black : .gray)
                    .fontWeight(selectedTab == title ? .bold : .regular)
                
                Rectangle()
                    .frame(height: 2)
                    .foregroundColor(selectedTab == title ? .blue : .gray)
                    .edgesIgnoringSafeArea(.horizontal)
            }
            .padding(.vertical, 8)
        }
        .frame(minWidth: 100)
    }
}

struct SettingsView: View {
    var body: some View {
        Text("Settings Screen")
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}

#Preview {
    ProfileView()
}
