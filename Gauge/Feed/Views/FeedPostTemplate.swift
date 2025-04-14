//
//  FeedPostTemplate.swift
//  Gauge
//
//  Created by Austin Huguenard on 4/10/25.
//

import SwiftUI

struct FeedPostWrapperView: View {
    let post: any Post
    @Binding var dragAmount: CGSize
    @Binding var optionSelected: Int
    @Binding var skipping: Bool

    var body: some View {
        if let binaryPost = post as? BinaryPost {
            BinaryFeedPost(
                post: binaryPost,
                dragAmount: $dragAmount,
                optionSelected: $optionSelected,
                skipping: $skipping
            )
            .onAppear {
                optionSelected = 0
            }
            .onChange(of: binaryPost.postId) { _, _ in
                optionSelected = 0
            }
        } else if let sliderPost = post as? SliderPost {
            SliderFeedPost(
                post: sliderPost,
                optionSelected: $optionSelected,
                dragAmount: $dragAmount
            )
            .onAppear {
                optionSelected = 3
            }
            .onChange(of: sliderPost.postId) { _, _ in
                optionSelected = 3
            }
        } else {
            Text("Unsupported post type")
        }
    }
}
