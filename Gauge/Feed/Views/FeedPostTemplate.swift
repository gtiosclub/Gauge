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
        } else if let sliderPost = post as? SliderPost {
            SliderFeedPost(
                post: sliderPost,
                optionSelected: $optionSelected,
                dragAmount: $dragAmount
            )
        } else {
            Text("Unsupported post type")
        }
    }
}
