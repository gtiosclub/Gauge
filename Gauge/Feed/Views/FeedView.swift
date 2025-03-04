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
    @State private var hasSkipped: Bool = false
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(Color(red: 187.0 / 255, green: 187.0 / 255, blue: 187.0 / 255))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.black, lineWidth: 0.5)
                    )
                    .padding(.horizontal, 12)
                
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(Color(red: 187.0 / 255, green: 187.0 / 255, blue: 187.0 / 255))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.black, lineWidth: 0.5)
                    )
                    .padding(.horizontal, 8)
                    .offset(y: dragOffset.height > 0 ? dragOffset.height / 15 : 0.0)
                    
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(Color(red: (min(255.0, 187.0 + dragOffset.height) / 255), green: (min(255.0, 187.0 + dragOffset.height) / 255), blue: (min(255.0, 187.0 + dragOffset.height) / 255)))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.black, lineWidth: 0.5)
                    )
                    .padding(.horizontal, 4)
                    .offset(y: 10 + (dragOffset.height > 0 ? dragOffset.height / 15 : 0.0))
                
                VStack {
                    if let post = postVM.feedPosts.first as? BinaryPost {
                        ZStack(alignment: .top) {
                            if isConfirmed {
                                BinaryFeedResults(post: post)
                            } else {
                                BinaryFeedPost(post: post, index: postVM.feedPosts.firstIndex(where: {$0.postId == post.postId})!, dragAmount: $dragOffset, optionSelected: $optionSelected)
                                    .rotatedBy(at: postVM.feedPosts.firstIndex(where: {$0.postId == post.postId})!, offset: $dragOffset)
                                    .frame(width: max(0, geo.size.width))
                            }
                            
                            if dragOffset.height > 0 {
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        .black.opacity(dragOffset.height / 100.0),
                                        .clear
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                                .cornerRadius(10.0)
                                .overlay(alignment: .top) {
                                    VStack {
                                        Text(!isConfirmed ? "SKIP" : "NEXT")
                                            .foregroundColor(.white)
                                            .bold()
                                            .opacity(dragOffset.height / 150.0)
                                        
                                        Image(systemName: "arrow.down")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 30, height: 30, alignment: .top)
                                            .foregroundStyle(.white)
                                            .opacity(dragOffset.height / 150.0)
                                        
                                        Spacer()
                                    }
                                    .frame(alignment: .top)
                                    .padding(.top)
                                }
                                .frame(width: max(0, geo.size.width))
                            }
                        }
//                        .frame(width: max(0, geo.size.width), height: max(0, geo.size.height - 20))
                    }
                }
                .frame(width: max(0, geo.size.width), height: max(0, geo.size.height - 20))
                .background {
                    RoundedRectangle(cornerRadius: 10.0)
                        .fill(Color.white)
                }
                .offset(y: dragOffset.height + 10)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            withAnimation {
                                if gesture.translation.height.magnitude > gesture.translation.width.magnitude {
                                    if !hasSkipped {
                                        dragOffset = CGSize(width: 0.0, height: gesture.translation.height)
                                    } else {
                                        dragOffset = CGSize(width: 0.0, height: 0.0)
                                    }
                                    
                                    if dragOffset.height < -150 {
                                        if optionSelected != 0 {
                                            if !isConfirmed && optionSelected == 1 {
                                                postVM.addView(responseOption: optionSelected)
                                            } else if !isConfirmed {
                                                postVM.addView(responseOption: optionSelected)
                                            }
                                            withAnimation {
                                                isConfirmed = true
                                            }
                                        }
                                        
                                        dragOffset = .zero
                                    }
                                    
                                    if dragOffset.height > 150 && !hasSkipped {
                                        hasSkipped = true
                                        optionSelected = 0
                                        if isConfirmed {
                                            // Next post logic
                                            postVM.feedPosts.remove(at: 0)
                                        } else {
                                            // Skip logic
                                            postVM.feedPosts.remove(at: 0)
                                        }
                                        isConfirmed = false
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
                            hasSkipped = false
                        }
                )
            }
            .frame(width: min(geo.size.width, UIScreen.main.bounds.width))
        }
        .onAppear() {
            postVM.addDummyPosts()
        }
    }
}

extension View {
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
