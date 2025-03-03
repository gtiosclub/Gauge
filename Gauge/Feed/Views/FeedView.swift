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
    @State private var dragOffset: CGSize = .zero
    @State private var opacityAmount = 1.0
    @State private var optionSelected: Int = 0
    @State private var isConfirmed: Bool = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .background(.white)
                .foregroundStyle(.gray.opacity(0.3))
            
            VStack {
                //                List {
                //                    ForEach(postVM.feedPosts.reversed(), id: \.postId) { post in
                
                
                if let post = postVM.feedPosts.first as? BinaryPost {
                    BinaryFeedPost(post: post, index: postVM.feedPosts.firstIndex(where: {$0.postId == post.postId})!, dragAmount: $dragOffset, optionSelected: $optionSelected)
                        .background(
                            RoundedRectangle(cornerRadius: 10.0)
                                .fill(.white)
                                .colored(at: postVM.feedPosts.firstIndex(where: {$0.postId == post.postId})!, in: 3)
                            
                        )
                    //                            .offset(dragOffset)
                        .stacked(at: postVM.feedPosts.firstIndex(where: {$0.postId == post.postId})!, in: 3, offset: $dragOffset)
                        .dimmed(at: postVM.feedPosts.firstIndex(where: {$0.postId == post.postId})!, in: 3)
                        .rotatedBy(at: postVM.feedPosts.firstIndex(where: {$0.postId == post.postId})!, offset: $dragOffset)
                        .gesture(
                            DragGesture()
                                .onChanged { gesture in
                                    withAnimation {
                                        if gesture.translation.height.magnitude > gesture.translation.width.magnitude {
                                            dragOffset = CGSize(width: 0.0, height: gesture.translation.height)
                                            
                                            if dragOffset.height < -150 {
                                                if optionSelected != 0 {
                                                    if !isConfirmed && optionSelected == 1 {
                                                        post.responseResult1 += 1
                                                    } else if !isConfirmed {
                                                        post.responseResult2 += 1
                                                    }
                                                    isConfirmed = true
                                                }
                                                
                                                dragOffset = .zero
                                            }
                                            
                                        } else {
                                            if gesture.translation.width.magnitude > 150 {
                                                dragOffset = .zero
                                                
                                                if gesture.translation.width > 0 {
                                                    optionSelected = 2
                                                } else {
                                                    optionSelected = 1
                                                }
                                                
                                            } else {
                                                dragOffset = .init(width: gesture.translation.width, height: 0.0)
                                            }
                                        }
                                    }
                                }
                                .onEnded { gesture in
                                    dragOffset = .zero
                                }
                        )
                        .frame(minHeight: 500.0)
                }
            }
//            .background {
//                RoundedRectangle(cornerRadius: 10.0)
//                    .foregroundStyle(.white)
//            }
            .offset(y: 10)
            .padding(.vertical)
        }
        .onAppear() {
            postVM.addDummyPosts()
        }
    }
}

extension View {
    func stacked(at position: Int, in total: Int, offset: Binding<CGSize>) -> some View {
        if position == 0 {
            return self.offset(x: offset.wrappedValue.width, y: offset.wrappedValue.height)
        }
        
        let offset = Double(total - position) + 1
        return self.offset(y: offset * 10)
    }
    
    func dimmed(at position: Int, in total: Int) -> some View {
        return self.opacity(1.0 * (1 / Double(position)))
    }
    
    func shrunk(at position: Int, in total: Int) -> some View {
        return self.frame(maxWidth: 1.0 * (1 / Double(position)))
    }
    
    func colored(at position: Int, in total: Int) -> some View {
        return self.background(position == 0 ? .white : .gray)
//        return self.background()
    }
    
    func rotatedBy(at position: Int, offset: Binding<CGSize>) -> some View {
        if position == 0 {
            return self.rotationEffect(.degrees(offset.wrappedValue.width / 10.0))
        } else {
            return self.rotationEffect(.degrees(0.0))
        }
    }
}

#Preview {
    FeedView()
        .environmentObject(UserFirebase())
        .environmentObject(PostFirebase())
}
