//
//  ProfileUsernameDateView.swift
//  Gauge
//
//  Created by Austin Huguenard on 4/9/25.
//

import SwiftUI

struct ProfileUsernameDateView: View {
    @EnvironmentObject var userVM: UserFirebase
    var profilePhoto: String = ""
    var dateTime: Date
    var username: String = ""
    var userId: String
    
    var body: some View {
        HStack{
            ProfilePictureView(profilePhoto: userVM.useridsToPhotosAndUsernames[userId]?.0 ?? "")
            
            Text(userVM.useridsToPhotosAndUsernames[userId]?.1 ?? "")
                .font(.system(size: 16))
                .foregroundStyle(.black)
            
            Text("•  \(DateConverter.timeAgo(from: dateTime))")
                .font(.system(size: 13))
                .foregroundStyle(.gray)
        }
        .padding(.leading)
        .task {
            do {
                try await userVM.populateUsernameAndProfilePhoto(userId: userId)
            } catch {
                print("error getting username + profile photo")
            }
        }
    }
}

struct ProfilePictureView: View {
    var profilePhoto: String
    
    var body: some View {
        if profilePhoto == "" {
            AnyView(Image(systemName: "person")
                .resizable()
                .scaledToFit()
                .frame(width: 18, height: 18)
                .background(Circle()
                    .fill(Color.gray.opacity(0.7))
                    .frame(width:30, height: 30)
                    .opacity(0.6)
                )
                .padding(.trailing, 8)
            )
        } else {
            AnyView(AsyncImage(url: URL(string: profilePhoto)) { image in
                image
                    .resizable()
                    .frame(width: 30, height: 30)
                    .clipShape(Circle())
                    .scaledToFill()
            } placeholder: {
                ProgressView() // Placeholder until the image is loaded
                    .frame(width: max(30, 30))
                    .clipShape(Circle())
            }
            )
        }
    }
}

//#Preview {
//    let mockUserVM = UserFirebase()
//
//    ProfileUsernameDateView(
//        profilePhoto: "",
//        dateTime: Date.now,
//        userId: "Rzqik2ISWBezcmBVVaoCbR4rCz92"
//    )
//    .environmentObject(mockUserVM)
//}

#Preview {
    let mockUserVM = UserFirebase()
    
    ProfileUsernameDateView(dateTime: Date.now, userId: "0RIEcQl2H9hUCL2DSDaMDg9scqg2")
        .environmentObject(mockUserVM)
}
