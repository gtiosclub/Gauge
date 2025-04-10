//
//  StackedProfiles.swift
//  Gauge
//
//  Created by Austin Huguenard on 4/10/25.
//

import SwiftUI

enum Side {
    case left
    case right
}

struct StackedProfiles: View {
    @EnvironmentObject var userVM: UserFirebase
    var userIds: [String]
    @State private var spacing: CGFloat = 15
    var sideOnTop: Side = .right
    var startCompacted: Bool = true

    var body: some View {
        ZStack(alignment: .leading) {
            ForEach(userIds.indices, id: \.self) { index in
                let userId = userIds[index]
                let profilePhoto = userVM.useridsToPhotosAndUsernames[userId]?.photoURL ?? ""

                ProfilePictureView(profilePhoto: profilePhoto)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 1)
                    )
                    .offset(x: sideOnTop == .left ? -CGFloat(index) * spacing : CGFloat(index) * spacing)
                    .task {
                        if userVM.useridsToPhotosAndUsernames[userId] == nil {
                            do {
                                try await userVM.populateUsernameAndProfilePhoto(userId: userId)
                            } catch {
                                print("Failed to load user \(userId): \(error)")
                            }
                        }
                    }
            }
        }
        .frame(height: userIds.count == 0 ? 0 : 30)
        .offset(x: userIds.count == 1 ? 0 : sideOnTop == .left ? spacing : -spacing) // offset by current spacing for balance
        .onTapGesture {
            withAnimation {
                spacing = (spacing == 15 ? 40 : 15)
            }
        }
        .onAppear {
            if !startCompacted {
                spacing = 40
            }
        }
    }
}

#Preview {
    let mockUserVM = UserFirebase()

    // Optional: preload with test data
    mockUserVM.useridsToPhotosAndUsernames = [
        "user1": ("https://pics.walgreens.com/prodimg/494944/900.jpg", "User One"),
        "user2": ("https://www.seriouseats.com/thmb/rkmijvOtxOQyH3D8n2q8uc67XNk=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/__opt__aboutcom__coeus__resources__content_migration__serious_eats__seriouseats.com__recipes__images__2015__04__20150323-cocktails-vicky-wasik-margarita-c84b154e757d43688de15dc8f8ca0de9.jpg", "User Two"),
        "user3": ("https://www.100daysofrealfood.com/wp-content/uploads/2011/06/popcorn1.jpg", "User Three")
    ]
    
    return StackedProfiles(userIds: ["user1", "user2", "user3"])
        .environmentObject(mockUserVM)
}
