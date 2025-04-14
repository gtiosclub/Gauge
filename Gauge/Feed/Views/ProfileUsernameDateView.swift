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
                .font(.system(size: 15))
                .foregroundStyle(.black)

            Text("•  \(DateConverter.timeAgo(from: dateTime)) ago")
                .font(.system(size: 15))
                .foregroundStyle(.gray)
        }
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
    @EnvironmentObject var userVM: UserFirebase
    
    var body: some View {
        if profilePhoto.count == 1 {
            AnyView(
                ZStack {
                    Circle()
                        .stroke(Color.white, lineWidth: 1)
                        .background(
                            Circle().fill(Color.lightGray)
                        )

                    Text(profilePhoto)
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                }
                .frame(width: 30, height: 30)
//                .padding(.trailing, 6)
                    
            )
            .alignmentGuide(.leading) { d in d[.leading] }
        } else if profilePhoto.isEmpty {
            AnyView(
                ZStack {
                    Circle()
                        .stroke(Color.white, lineWidth: 1)
                        .background(
                            Circle().fill(Color.lightGray)
                        )

                    Image(systemName: "person")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                        .foregroundColor(.white)
                }
                .frame(width: 30, height: 30)
//                .padding(.trailing, 6)
                   
            )
            .alignmentGuide(.leading) { d in d[.leading] }
        } else {
            AnyView(AsyncImage(url: URL(string: profilePhoto)) { image in
                image
                    .resizable()
                    .frame(width: 30, height: 30)
                    .clipShape(Circle())
                    .scaledToFill()
            } placeholder: {
                ZStack {
                    Circle()
                        .stroke(Color.white, lineWidth: 1)
                        .background(
                            Circle().fill(Color.lightGray)
                        )

                    Image(systemName: "person")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                        .foregroundColor(.white)
                }
                .frame(width: 30, height: 30)
//                .padding(.trailing, 6)
            }
            )
            .alignmentGuide(.leading) { d in d[.leading] }
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
