//
//  TakeTimeView.swift
//  Gauge
//
//  Created by Nikola Cao on 4/3/25.
//

import SwiftUI
import FirebaseFirestore

struct Take: Identifiable, Codable {
    @DocumentID var id: String?
    var take: String
    var category: String
    var topic: String
    var createdAt: Date?
}

class TakesVM: ObservableObject {
    @Published var takes: [Take] = []
    @Published var binaryposts: [BinaryPost] = []
    
    private var db = Firestore.firestore()
    
    init() {
        fetchTakes()
        
        for elm in takes {
            
            binaryposts.append(
                BinaryPost(
                    postId: "",
                    userId: "",
                    username: "",
                    comments: [],
                    responses: [],
                    categories: [],
                    viewCounter: 1_020,
                    postDateAndTime: Date(),
                    question: elm.take,
                    responseOption1: "No",
                    responseOption2: "Yes",
                    responseResult1: 0,
                    responseResult2: 0,
                    favoritedBy: []
            ))
        }
    }
    
    func addView(responseOption: Int) {
        if let post = binaryposts.first as? BinaryPost {
            if responseOption == 1 {
                post.responseResult1 += 1
            } else if responseOption == 2 {
                post.responseResult2 += 1
            }
        }
    }
    
    func fetchTakes() {
        db.collection("TakeTime")
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching takes: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                self.takes = documents.compactMap { document in
                    try? document.data(as: Take.self)
                }
            }
    }
}

struct TakeTimeTakesView: View {
//    @EnvironmentObject var userVM: UserFirebase
//    @EnvironmentObject var postVM: PostFirebase
    @State private var dragOffset: CGSize = .zero
    @State private var opacityAmount = 1.0
    @State private var optionSelected: Int = 0
    @State private var isConfirmed: Bool = false
    @State private var hasSkipped: Bool = false
    @StateObject var takeVM = TakesVM()
    
    var body: some View {
        GeometryReader { geo in
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
                        if takeVM.binaryposts.indices.contains(1), let post = takeVM.binaryposts[1] as? BinaryPost {
                            TakeTimeBinaryPost(post: post, dragAmount: .constant(CGSize(width: 0.0, height: 0.0)), optionSelected: .constant(0), skipping: $hasSkipped)
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
                    if let post = takeVM.binaryposts.first as? BinaryPost {
                        ZStack(alignment: .top) {
                            TakeTimeBinaryPost(post: post, dragAmount: $dragOffset, optionSelected: $optionSelected, skipping: $hasSkipped)
                                .frame(width: max(0, geo.size.width))
                            
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
                                            if !isConfirmed && optionSelected == 1 {
                                                takeVM.addView(responseOption: optionSelected)
                                            } else if !isConfirmed {
                                                takeVM.addView(responseOption: optionSelected)
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
                                        isConfirmed = false
                                    }
                                    
                                } else {
                                    if gesture.translation.width.magnitude > 150 {
                                        dragOffset = .zero
                                        
                                        if gesture.translation.width > 0 {
                                            optionSelected = 2
                                            takeVM.addView(responseOption: optionSelected)
                                            withAnimation {
                                                isConfirmed = true
                                            }
                                            dragOffset = .zero
                                        } else {
                                            optionSelected = 1
                                            takeVM.addView(responseOption: optionSelected)
                                            withAnimation {
                                                isConfirmed = true
                                            }
                                            dragOffset = .zero
                                        }
                                        
                                        
                                    } else {
                                        dragOffset = .init(width: gesture.translation.width, height: 0.0)
                                    }
                                }
                            }
                        }
                        .onEnded { gesture in
                            if isConfirmed {
                                // Next post logic
                                takeVM.binaryposts.remove(at: 0)
                            } else {
                                // Skip logic
                                takeVM.binaryposts.remove(at: 0)
                            }
                            isConfirmed = false
                            optionSelected = 0
                        
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
//        .onAppear() {
//            postVM.addDummyPosts()
//        }
    }
}

#Preview {
    TakeTimeTakesView()
//        .environmentObject(UserFirebase())
//        .environmentObject(PostFirebase())
}
