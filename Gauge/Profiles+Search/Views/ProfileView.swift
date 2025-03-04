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

                        Button(action: {}) {
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
                    if selectedTab == "Takes" {
                        ScrollView {
                            VStack(spacing: 12) {
                                TakeCard()
                                TakeCard()
                                TakeCard()
                            }
                            .padding()
                        }
                    } else {
                        Text("\(selectedTab) Content Here")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color(UIColor.systemGray6))
                    }
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

struct TakeCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                Circle()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.gray)

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text("username")
                            .font(.headline)
                            .fontWeight(.bold)

                        Image(systemName: "diamond.fill")
                            .resizable()
                            .frame(width: 12, height: 12)
                            .foregroundColor(.gray)

                        Text("• 2d ago")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                Spacer()
            }

            HStack(spacing: 6) {
                TagView(text: "#tag1")
                TagView(text: "#tag2")
                TagView(text: "#tag3")
            }

            Text("username own personal take on something controversial")
                .font(.body)
                .foregroundColor(.black)
                .padding(.top, 2)

            HStack {
                Text("100 votes")
                    .font(.caption)
                    .foregroundColor(.gray)

                Spacer()

                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "bubble.left")
                        Text("10")
                    }

                    HStack(spacing: 4) {
                        Image(systemName: "eye")
                        Text("200")
                    }

                    Image(systemName: "bookmark")

                    Image(systemName: "square.and.arrow.up")
                }
                .font(.caption)
                .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.gray.opacity(0.2), radius: 5, x: 0, y: 2)
    }
}

struct TagView: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color(UIColor.systemGray6))
            .cornerRadius(8)
    }
}

struct SettingsView: View {
    var body: some View {
        Text("Settings Screen")
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ProfileView()
}
