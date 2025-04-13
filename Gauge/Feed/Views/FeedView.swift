//
//  FeedView.swift
//  Gauge
//
//  Created by Austin Huguenard on 3/2/25.
//

import SwiftUI
import SwiftData

struct FeedView: View {
    @EnvironmentObject var userVM: UserFirebase
    @EnvironmentObject var postVM: PostFirebase
    @Environment(\.modelContext) private var modelContext
    @State private var dragOffset: CGSize = .zero
    @State private var opacityAmount = 1.0
    @State private var optionSelected: Int = 0
    @State private var isConfirmed: Bool = false
    @State private var hasSkipped: Bool = false
    
    @State private var showPostCreation: Bool = false
    @State private var modalSize: CGFloat = 380
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                if !isConfirmed {
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
                            showPostCreation = true
                        } label: {
                            Image(systemName: "plus.rectangle")
                                .resizable()
                                .scaledToFill()
                                .rotationEffect(.degrees(90))
                                .frame(width: 18, height: 18)
                                .foregroundStyle(.white)
                        }
                        
                        Button {
                            if postVM.skippedPost != nil {
                                UserResponsesManager.addCategoriesToUserResponses(modelContext: modelContext, categories: postVM.skippedPost!.categories.map{$0.rawValue})
                                UserResponsesManager.addTopicsToUserResponses(modelContext: modelContext, topics: postVM.skippedPost!.topics)
                            }
                            postVM.undoSkipPost(userId: userVM.user.userId)
                            
                            Task {
                                try await userVM.updateUserNextPosts(userId: userVM.user.userId, postIds: postVM.feedPosts.map { $0.postId })
                            }
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
                }
                
                ZStack {
                    HStack {
                        RoundedRectangle(cornerRadius: 20.0)
                            .frame(width: geo.size.width - 26 + (dragOffset.height > 0 ? (dragOffset.height != 800.0 ? min(dragOffset.height / 8, 8) : 8.0) : 0.0))
                            .overlay {
                                RoundedRectangle(cornerRadius: 20.0)
                                    .fill(Color.mediumGray)
                            }
                            .frame(width: geo.size.width - 32 + (dragOffset.height > 0 ? (dragOffset.height != 800.0 ? min(dragOffset.height / 8, 8) : 8.0) : 0.0))
                    }
                    
                    HStack {
                        RoundedRectangle(cornerRadius: 20.0)
                            .frame(width: geo.size.width - 18 + (dragOffset.height > 0 ? (dragOffset.height != 800.0 ? min(dragOffset.height / 8, 12) : 12.0) : 0.0))
                            .overlay {
                                RoundedRectangle(cornerRadius: 20.0)
                                    .fill(Color(red: (min(209.0, 187.0 + dragOffset.height) / 255),
                                                green: (min(209.0, 187.0 + dragOffset.height) / 255),
                                                blue: (min(209.0, 187.0 + dragOffset.height) / 255)))
                            }
                            .offset(y: dragOffset.height > 0 ? (dragOffset.height != 800.0 ? min(dragOffset.height / 10.0, 10.0) : 10.0) : 0.0)
                    }
                    .frame(maxWidth: geo.size.width - 24 + (dragOffset.height > 0 ? (dragOffset.height != 800.0 ? min(dragOffset.height / 8, 12.0) : 12.0) : 0.0))
                    
                    withAnimation(.none) {
                        HStack {
                            if postVM.feedPosts.indices.contains(1), let post = postVM.feedPosts[1] as? BinaryPost {
                                BinaryFeedPost(post: post, dragAmount: .constant(CGSize(width: 0.0, height: 0.0)), optionSelected: .constant(0), skipping: $hasSkipped)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20.0)
                                            .fill(Color(red: (min(255.0, 209.0 + dragOffset.height) / 255),
                                                        green: (min(255.0, 209.0 + dragOffset.height) / 255),
                                                        blue: (min(255.0, 209.0 + dragOffset.height) / 255)))
                                    )
                                    .frame(width: max(0, geo.size.width - 6 + (dragOffset.height > 0 ? (dragOffset.height != 800.0 ? min(dragOffset.height / 20.0, 6.0) : 6.0) : 0.0)))
                                    .offset(y: 10 + (dragOffset.height > 0 ? (dragOffset.height != 800.0 ? min(dragOffset.height / 10.0, 10.0) : 10.0) : 0.0))
                                    .mask(RoundedRectangle(cornerRadius: 20.0).offset(y: 10))
                            } else if postVM.feedPosts.indices.contains(1), let post = postVM.feedPosts[1] as? SliderPost {
                                SliderFeedPost(post: post, optionSelected: $optionSelected, dragAmount: $dragOffset)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20.0)
                                            .fill(Color(red: (min(255.0, 209.0 + dragOffset.height) / 255),
                                                        green: (min(255.0, 209.0 + dragOffset.height) / 255),
                                                        blue: (min(255.0, 209.0 + dragOffset.height) / 255)))
                                    )
                                    .frame(width: max(0, geo.size.width - 6 + (dragOffset.height > 0 ? (dragOffset.height != 800.0 ? min(dragOffset.height / 20.0, 6.0) : 6.0) : 0.0)))
                                    .offset(y: 10 + (dragOffset.height > 0 ? (dragOffset.height != 800.0 ? min(dragOffset.height / 10.0, 10.0) : 10.0) : 0.0))
                                    .mask(RoundedRectangle(cornerRadius: 20.0).offset(y: 10))
                            }
                        }
                    }
                    
                    VStack {
                        if let post = postVM.feedPosts.first {
                            ZStack(alignment: .top) {
                                if isConfirmed {
                                    if let binaryPost = post as? BinaryPost {
                                        BinaryFeedResults(post: binaryPost, optionSelected: optionSelected)
                                    } else if let sliderPost = post as? SliderPost {
                                        SliderFeedResults(post: sliderPost, optionSelected: optionSelected)
                                    }
                                } else {
                                    FeedPostWrapperView(
                                        post: post,
                                        dragAmount: $dragOffset,
                                        optionSelected: $optionSelected,
                                        skipping: $hasSkipped
                                    )
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
                        } else if postVM.feedPosts.count == 0 {
                            Text("Finding Your Optimal Posts...")
                                .font(.title)
                            ProgressView()
                                .scaleEffect(5.0)
                                .frame(width: 200, height: 200)
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
                    .rotatedBy(offset: $dragOffset, doAnimation: (postVM.feedPosts.count > 0 && !isConfirmed && postVM.feedPosts.first! is BinaryPost))
                    .offset(y: dragOffset.height + 20)
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                if postVM.feedPosts.count == 0 {
                                    return
                                }
                                
                                withAnimation {
                                    if gesture.translation.height.magnitude > gesture.translation.width.magnitude {
                                        if !hasSkipped {
                                            let currentPost = postVM.feedPosts.first
                                            let isBinary = currentPost is BinaryPost
                                            let isSlider = currentPost is SliderPost

                                            let shouldDragUp = ((isBinary && optionSelected != 0) || (isSlider && optionSelected != 3)) && !isConfirmed

                                            if (shouldDragUp && gesture.translation.height < 0) || gesture.translation.height > 0 {
                                                dragOffset = CGSize(width: 0.0, height: gesture.translation.height)
                                            }
                                        } else {
                                            withAnimation(.smooth(duration: 0.5)) {
                                                dragOffset = CGSize(width: 0.0, height: geo.size.height)
                                            }
                                        }
                                        
                                        if dragOffset.height < -150 {
                                            if let post = postVM.feedPosts.first {
                                                let user = userVM.user
                                                let shouldSubmit: Bool

                                                if let binaryPost = post as? BinaryPost {
                                                    shouldSubmit = optionSelected != 0
                                                    if shouldSubmit && !isConfirmed {
                                                        let responseChosen = (optionSelected == 1) ? binaryPost.responseOption1 : binaryPost.responseOption2
                                                        postVM.addResponse(postId: binaryPost.postId, userId: user.userId, responseOption: responseChosen)
                                                        UserResponsesManager.addCategoriesToUserResponses(modelContext: modelContext, categories: post.categories.map{$0.rawValue})
                                                        UserResponsesManager.addTopicsToUserResponses(modelContext: modelContext, topics: post.topics)

                                                        
                                                    }
                                                } else if let sliderPost = post as? SliderPost {
                                                    shouldSubmit = optionSelected != 3
                                                    if shouldSubmit && !isConfirmed {
                                                        postVM.addResponse(postId: sliderPost.postId, userId: user.userId, responseOption: (optionSelected < 3 ? String(optionSelected + 1) : String(optionSelected)))
                                                        UserResponsesManager.addCategoriesToUserResponses(modelContext: modelContext, categories: post.categories.map{$0.rawValue})
                                                        UserResponsesManager.addTopicsToUserResponses(modelContext: modelContext, topics: post.topics)
                                                    }
                                                } else {
                                                    shouldSubmit = false
                                                }

                                                if shouldSubmit {
                                                    isConfirmed = true
                                                }
                                            }
                                            
                                            dragOffset = .zero
                                        }
                                        
                                        if dragOffset.height > 150 && !hasSkipped {
                                            hasSkipped = true
                                            optionSelected = 0
                                        }
                                    } else {
                                        if let post = postVM.feedPosts.first, post is SliderPost {
                                            return
                                        }
                                        
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
                                        postVM.feedPosts.removeFirst()
                                        postVM.findNextPost(user: userVM.user)
                                        postVM.skippedPost = nil
                                    } else {
                                        // Skip logic
                                        postVM.skippedPost = postVM.skipPost(user: userVM.user)
                                        if postVM.skippedPost != nil {
                                            UserResponsesManager.removeCategoriesFromUserResponses(modelContext: modelContext, categories: postVM.skippedPost!.categories.map{$0.rawValue})
                                            UserResponsesManager.removeTopicsFromUserResponses(modelContext: modelContext, topics: postVM.skippedPost!.topics)
                                            
                                        }
                                    }
                                    withAnimation {
                                        isConfirmed = false
                                    }
                                    Task {
                                        try await userVM.updateUserNextPosts(userId: userVM.user.userId, postIds: postVM.feedPosts.map { $0.postId })
                                    }
                                }
//                                withAnimation() {
                                    dragOffset = .zero
//                                }
                                hasSkipped = false
                            }
                    )
                    .opacity(hasSkipped ? 0.0 : 1.0)
                }
                .frame(width: min(geo.size.width, UIScreen.main.bounds.width))
                .background(.black)
            }
            .background(.black)
            .sheet(isPresented: $showPostCreation) {
                PostCreationView(modalSize: $modalSize, showCreatePost: $showPostCreation)
                    .presentationDetents([.height(modalSize)])
                    .presentationBackground(.clear)
                    .background(
                        RoundedRectangle(cornerRadius: 36, style: .continuous)
                            .fill(Color.white)
                    )
                    .padding(.horizontal, 10)
            }
        }
    }
}

extension View {
    func rotatedBy(offset: Binding<CGSize>, doAnimation: Bool) -> some View {
        return self.rotationEffect(doAnimation ? .degrees(offset.wrappedValue.width / 10.0) : .degrees(0))
    }
}

#Preview {
    FeedView()
        .environmentObject(UserFirebase())
        .environmentObject(PostFirebase())
}
