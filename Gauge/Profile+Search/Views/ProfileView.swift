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
        VStack {
            HStack {
                Circle()
                    .frame(width: 60, height: 60)
                    .foregroundColor(.gray)

                VStack(alignment: .leading) {
                    Text("username")
                        .font(.headline)
                    
                    Button(action: {
                    }) {
                        Text("Edit Profile")
                            .font(.caption)
                            .padding(6)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.black, lineWidth: 1)
                            )
                    }
                }
                Spacer()
            }
            .padding()

            HStack {
                TabButton(title: "Takes", selectedTab: $selectedTab)
                TabButton(title: "Votes", selectedTab: $selectedTab)
                TabButton(title: "Comments", selectedTab: $selectedTab)
                TabButton(title: "Badges", selectedTab: $selectedTab)
            }
            .padding(.horizontal)

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
    }
}

struct TabButton: View {
    let title: String
    @Binding var selectedTab: String

    var body: some View {
        Button(action: {
            selectedTab = title
        }) {
            VStack {
                Text(title)
                    .foregroundColor(selectedTab == title ? .black : .gray)
                    .fontWeight(selectedTab == title ? .bold : .regular)
                
                if selectedTab == title {
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(.blue)
                } else {
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(.clear)
                }
            }
            .padding(.vertical, 5)
        }
        .frame(maxWidth: .infinity)
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
