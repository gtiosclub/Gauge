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
            VStack {
                HStack(spacing: (geo.size.width / 3.0)) {
                    Button {
                        //TODO: Insert Button action here
                        print("Filter Button")
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 13, height: 13)
                            .foregroundStyle(.white)
                    }
                    
                    Button {
                        //TODO: Insert Button action here
                        print("Create Button")
                    } label: {
                        Image(systemName: "plus.square")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 18, height: 18)
                            .foregroundStyle(.white)
                    }
                    
                    Button {
                        //TODO: Insert Button action here
                        print("Undo Button")
                    } label: {
                        Image(systemName: "arrow.uturn.backward")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 18, height: 18)
                            .foregroundStyle((postVM.skippedPost == nil) ? .gray : .white)
                    }
                    .disabled((postVM.skippedPost == nil))
                }
                .bold()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .padding(.bottom, 10)
                
                ZStack {
                    HStack {
                        RoundedRectangle(cornerRadius: 20.0)
                            .frame(width: geo.size.width - 26 + (dragOffset.height > 0 ? (dragOffset.height != 800.0 ? min(dragOffset.height / 8, 8) : 8.0) : 0.0))
                            .overlay {
                                RoundedRectangle(cornerRadius: 20.0)
                                    .fill(Color.mediumGray)
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.black, lineWidth: 0.5)
                            )
                            .frame(width: geo.size.width - 32 + (dragOffset.height > 0 ? (dragOffset.height != 800.0 ? min(dragOffset.height / 8, 8) : 8.0) : 0.0))
                    }
                    
                    HStack {
                        RoundedRectangle(cornerRadius: 20.0)
                            .frame(width: geo.size.width - 18 + (dragOffset.height > 0 ? (dragOffset.height != 800.0 ? min(dragOffset.height / 8, 12) : 12.0) : 0.0))
                            .overlay {
                                RoundedRectangle(cornerRadius: 20.0)
                                    .fill(Color.mediumGray)
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.black, lineWidth: 0.5)
                            )
                            .offset(y: dragOffset.height > 0 ? (dragOffset.height != 800.0 ? min(dragOffset.height / 10.0, 10.0) : 10.0) : 0.0)
                    }
                    .frame(maxWidth: geo.size.width - 24 + (dragOffset.height > 0 ? (dragOffset.height != 800.0 ? min(dragOffset.height / 8, 12.0) : 12.0) : 0.0))
                    
                    withAnimation(.none) {
                        HStack {
                            if postVM.feedPosts.indices.contains(1), let post = postVM.feedPosts[1] as? BinaryPost {
                                BinaryFeedPost(post: post, dragAmount: .constant(CGSize(width: 0.0, height: 0.0)), optionSelected: .constant(0), skipping: $hasSkipped)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20.0)
                                            .fill(Color(red: (min(255.0, 187.0 + dragOffset.height) / 255),
                                                        green: (min(255.0, 187.0 + dragOffset.height) / 255),
                                                        blue: (min(255.0, 187.0 + dragOffset.height) / 255)))
                                    )
                                    .frame(width: max(0, geo.size.width - 6 + (dragOffset.height > 0 ? (dragOffset.height != 800.0 ? min(dragOffset.height / 20.0, 6.0) : 6.0) : 0.0)))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.black.opacity(hasSkipped ? 0.0 : dragOffset.height > 0 ? (dragOffset.height < 150.0 ? max(100 - dragOffset.height / 150.0, 0.0) : 0.0) : 1.0), lineWidth: 0.5)
                                    )
                                    .offset(y: 10 + (dragOffset.height > 0 ? (dragOffset.height != 800.0 ? min(dragOffset.height / 10.0, 10.0) : 10.0) : 0.0))
                                    .mask(RoundedRectangle(cornerRadius: 20.0).offset(y: 10))
                            }
                            
                        }
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
                                    .cornerRadius(20.0)
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
                            .frame(height: 1008.0)
                    }
                    
                    .frame(width: max(0, geo.size.width), height: max(0, geo.size.height + 1000))
                    .background {
                        RoundedRectangle(cornerRadius: 20.0)
                            .fill(Color.white)
                    }
                    .rotatedBy(offset: $dragOffset)
                    .offset(y: dragOffset.height + 20)
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                withAnimation {
                                    if gesture.translation.height.magnitude > gesture.translation.width.magnitude {
                                        if !hasSkipped {
                                            dragOffset = CGSize(width: 0.0, height: gesture.translation.height)
                                        } else {
                                            withAnimation(.smooth(duration: 0.5)) {
                                                dragOffset = CGSize(width: 0.0, height: 800.0)
                                            }
                                        }
                                        
                                        if dragOffset.height < -150 {
                                            if optionSelected != 0 {
                                                if !isConfirmed {
                                                    let user = userVM.user
                                                    if let post = postVM.feedPosts.first as? BinaryPost {
                                                        var responseChosen = "NA"
                                                        if(optionSelected == 1 ){
                                                            responseChosen = post.responseOption1
                                                            post.responseResult1 += 1
                                                        } else if(optionSelected == 2){
                                                            responseChosen = post.responseOption2
                                                            post.responseResult2 += 1
                                                        }
                                                        postVM.addResponse(postId: post.postId, userId: user.userId, responseOption: responseChosen)
                                                    }
                                                }
                                                withAnimation {
                                                    isConfirmed = true
                                                }
                                            }
                                            
                                            dragOffset = .zero
                                        }
                                        
                                        if dragOffset.height > 150 && !hasSkipped {
                                            hasSkipped = true
                                            if(isConfirmed == false){
                                                if let post = postVM.feedPosts.first as? BinaryPost {
                                                    let user = userVM.user
                                                    postVM.addViewToPost(postId: post.postId, userId: user.userId)
                                                }
                                            }
                                            optionSelected = 0
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
                                if dragOffset.height > 150 && hasSkipped {
                                    if isConfirmed {
                                        // Next post logic
                                        postVM.feedPosts.remove(at: 0)
                                    } else {
                                        // Skip logic
                                        postVM.feedPosts.remove(at: 0)
                                    }
                                    isConfirmed = false
                                }
                                
                                //                            withAnimation(.none) {
                                dragOffset = .zero
                                hasSkipped = false
                                //                            }
                            }
                    )
                    .opacity(hasSkipped ? 0.0 : 1.0)
                }
                .frame(width: min(geo.size.width, UIScreen.main.bounds.width))
                .background(.black)
            }
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
