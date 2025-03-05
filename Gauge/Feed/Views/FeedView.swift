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
                    .offset(y: dragOffset.height > 0 && dragOffset.height != 800.0 ? dragOffset.height / 15 : 0.0)
                
                if postVM.feedPosts.indices.contains(1), let post = postVM.feedPosts[hasSkipped ? 0 : 1] as? BinaryPost {
                    BinaryFeedPost(post: post, dragAmount: .constant(CGSize(width: 0.0, height: 0.0)), optionSelected: .constant(0), skipping: $hasSkipped)
                        .frame(width: max(0, geo.size.width))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.black, lineWidth: 0.5)
                        )
                        .offset(y: 10 + (dragOffset.height > 0 && dragOffset.height != 800.0 ? dragOffset.height / 15 : 0.0) + (hasSkipped ? 10 : 0))
                        .background {
                            RoundedRectangle(cornerRadius: 10.0)
                                .fill(Color(red: (min(255.0, 187.0 + dragOffset.height) / 255), green: (min(255.0, 187.0 + dragOffset.height) / 255), blue: (min(255.0, 187.0 + dragOffset.height) / 255)))
                        }
//                        .padding(.horizontal, 4)
                        .frame(width: min(geo.size.width - 8, UIScreen.main.bounds.width - 8))
                }
                
                VStack {
                    if let post = postVM.feedPosts.first as? BinaryPost {
                        ZStack(alignment: .top) {
                            if isConfirmed {
                                BinaryFeedResults(post: post, optionSelected: optionSelected)
                            } else {
                                BinaryFeedPost(post: post, dragAmount: $dragOffset, optionSelected: $optionSelected, skipping: $hasSkipped)
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
                    }
                    
                    RoundedRectangle(cornerRadius: 10.0)
                        .fill(.white)
                        .frame(height: 1000.0)
                }
                .rotatedBy(offset: $dragOffset)
                .frame(width: max(0, geo.size.width), height: max(0, geo.size.height + 1000))
                .background {
                    RoundedRectangle(cornerRadius: 10.0)
                        .fill(Color.white)
                }
                .offset(y: dragOffset.height + 20)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            withAnimation {
                                if gesture.translation.height.magnitude > gesture.translation.width.magnitude {
                                    if !hasSkipped {
                                        dragOffset = CGSize(width: 0.0, height: gesture.translation.height)
                                    } else {
                                        dragOffset = CGSize(width: 0.0, height: 800.0)
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
                .opacity(hasSkipped ? 0.0 : 1.0)
            }
            .frame(width: min(geo.size.width, UIScreen.main.bounds.width))
            .background(.black)
        }
        .onAppear() {
            postVM.addDummyPosts()
        }
    }
}

extension View {
    func rotatedBy(offset: Binding<CGSize>) -> some View {
        return self.rotationEffect(.degrees(offset.wrappedValue.width / 10.0))
    }
}

#Preview {
    FeedView()
        .environmentObject(UserFirebase())
        .environmentObject(PostFirebase())
}
