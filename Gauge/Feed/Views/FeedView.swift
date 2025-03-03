//
//  FeedView.swift
//  Gauge
//
//  Created by Austin Huguenard on 3/2/25.
//

import SwiftUI

struct FeedView: View {
    @EnvironmentObject var userVM: UserFirebase
    @EnvironmentObject var postVM: PostFirebase
    
    var body: some View {
        ZStack {
            ForEach(postVM.feedPosts.reversed(), id: \.postId) { post in
                if post is BinaryPost {
                    BinaryFeedPost(post: post as! BinaryPost)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white)
                        )
                }
            }
        }
        .onAppear() {
            postVM.addDummyPosts()
        }
    }
}

#Preview {
    FeedView()
        .environmentObject(UserFirebase())
        .environmentObject(PostFirebase())
}
