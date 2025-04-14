//
//  SwipeableSheetView.swift
//  Gauge
//
//  Created by amber verma on 4/14/25.
//

import SwiftUI
struct SwipeableSheetView: View {
    let post: BinaryPost
    @EnvironmentObject var userVM: UserFirebase
    @EnvironmentObject var postVM: PostFirebase
    @State private var dragAmount: CGSize = .zero
    @State private var optionSelected: Int = 0
    @State private var isConfirmed: Bool = false
    @State private var hasResponded: Bool = false
    var body: some View {
        ZStack {
            if isConfirmed || hasResponded {
                BinaryFeedResults(
                    post: post,
                    optionSelected: optionSelected
                )
            } else {
                FeedPostWrapperView(
                    post: post,
                    dragAmount: $dragAmount,
                    optionSelected: $optionSelected,
                    skipping: .constant(false)
                )
                .gesture(
                    DragGesture()
                        .onEnded { gesture in
                            if abs(gesture.translation.width) > 100 && optionSelected == 0 {
                                optionSelected = gesture.translation.width > 0 ? 2 : 1
                                let selectedResponse = optionSelected == 1 ? post.responseOption1 : post.responseOption2
                                postVM.addResponse(
                                    postId: post.postId,
                                    userId: userVM.user.userId,
                                    responseOption: selectedResponse
                                )
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                    isConfirmed = true
                                }
                            }
                        }
                )
            }
        }
        .onAppear {
            postVM.getUserResponseForComment(postId: post.postId, userId: userVM.user.userId) { responseOption in
                if let option = responseOption {
                    DispatchQueue.main.async {
                        optionSelected = option == post.responseOption1 ? 1 : 2
                        hasResponded = true
                    }
                }
            }
        }
    }
}
