//
//  ProfileEditView.swift
//  Gauge
//
//  Created by Sam Orouji on 2/25/25.
//

import SwiftUI

struct ProfileEditView: View {
    @State private var username: String = ""
    
    var body: some View {
        VStack {
            Section {
                HStack {
                    NavigationLink(destination: ProfileEditView()) {
                        Button("Cancel") {}
                    }
                    
                    Spacer() // Pushes "Save" button to the right
                    Button("Save") {}
                }
                .padding(.horizontal) // Adds even horizontal padding
            }
            
            Circle()
                .frame(width: 150, height: 150)
                .foregroundColor(Color.gray)
            
            Spacer()
                .frame(height: 50)
            
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 20) {
                    Text("Username")
                        .frame(width: 80, alignment: .leading) // Ensures text aligns
                    TextField("new username", text: $username)
                        .textFieldStyle(PlainTextFieldStyle()) // Remove text box
                        .foregroundColor(.primary)
                }
                .padding(.leading, 20) // Consistent left padding
                .padding(.bottom, 5)
                .padding(.top, 5)
                
                Divider()
                
                HStack(spacing: 20) {
                    Text("Pronouns")
                        .frame(width: 80, alignment: .leading)
                    TextField("Pronouns", text: $username)
                        .textFieldStyle(PlainTextFieldStyle())
                        .foregroundColor(.primary)
                }
                .padding(.leading, 20)
                .padding(.bottom, 5)
                .padding(.top, 5)
                
                Divider()
                
                HStack(spacing: 20) {
                    Text("Bio")
                        .frame(width: 80, alignment: .leading)
                    TextField("a short bio that describes the user", text: $username)
                        .textFieldStyle(PlainTextFieldStyle())
                        .foregroundColor(.primary)
                }
                .padding(.leading, 20)
                .padding(.bottom, 5)
                .padding(.top, 5)

                
                Divider()
                
                HStack {
                    Text("User Tags")
                    Spacer()
                    NavigationLink(destination: ProfileEditView()) {
                        HStack {
                            Text("4")
                            Image(systemName: "chevron.right")
                        }
                    }
                }
                .padding(.horizontal, 20) // Align with previous elements
                .padding(.bottom, 5)
                .padding(.top, 5)

                
                Divider()
                
                HStack {
                    Text("Badges")
                    Spacer()
                    NavigationLink(destination: ProfileEditView()) {
                        HStack {
                            Text("5")
                            Image(systemName: "chevron.right")
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 5)
                .padding(.bottom , 5)
                
            }
            .frame(maxWidth: .infinity, alignment: .leading) // Ensures everything aligns to the left
            
            Spacer()
            
            Divider()
            
            HStack {
                VStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.gray)
                        .font(.system(size: 24))
                    Text("Tab Name")
                        .foregroundColor(.gray)
                        .font(.system(size: 12))
                }
                
                Spacer()
                
                VStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.gray)
                        .font(.system(size: 24))
                    Text("Tab Name")
                        .foregroundColor(.gray)
                        .font(.system(size: 12))
                }
                
                Spacer()
                
                VStack {
                    Image(systemName: "person.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 24))
                    Text("Profile")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.blue)
                        .font(.system(size: 12))
                }
            }
            .padding(.horizontal, 40) // Ensures even padding for tab bar items
        }
    }
}


    
    
    
    #Preview {
        ProfileEditView()
    }
