//
//  TakeTimeView.swift
//  Gauge
//
//  Created by Nikola Cao on 4/3/25.
//

import FirebaseFirestore
import SwiftUI

struct Take: Identifiable, Codable {
    @DocumentID var id: String?
    var question: String
    var responseOption1: String
    var responseOption2: String
    var category: String
    var topic: String
    var createdAt: Date?
}

class TakesVM: ObservableObject {
    @Published var takes: [Take] = []
    @Published var binaryposts: [BinaryPost] = []
    @Published var userResponses: [String: Int] = [:]
    private var loadedTakeIDs: Set<String> = []

    private var db = Firestore.firestore()

    init() {
        fetchTakes()
    }

    func fetchTakes() {
        db.collection("TakeTime")
            .order(by: "createdAt", descending: false)
            .limit(to: 5)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching takes: \(error.localizedDescription)")
                    return
                }

                guard let documents = snapshot?.documents else { return }
                let newTakes = documents.compactMap { document -> Take? in
                    let take = try? document.data(as: Take.self)
                    if let id = take?.id, !self.loadedTakeIDs.contains(id) {
                        self.loadedTakeIDs.insert(id)
                        return take
                    }
                    return nil
                }

                self.takes.append(contentsOf: newTakes)
                print("Fetched \(self.takes.count) takes")

                let newBinaryPosts = newTakes.map {
                    BinaryPost(
                        postId: "",
                        userId: "",
                        username: "",
                        profilePhoto: "",
                        comments: [],
                        responses: [],
                        categories: [],
                        topics: [],
                        viewCounter: 1020,
                        postDateAndTime: Date(),
                        question: $0.question,
                        responseOption1: $0.responseOption1,
                        responseOption2: $0.responseOption2,
                        sublabel1: "",
                        sublabel2: "",
                        favoritedBy: []
                    )
                }
                self.binaryposts.append(contentsOf: newBinaryPosts)

                print("BinaryPosts: \(self.binaryposts)")
            }
    }

    func addView(responseOption: Int, userId: String) {
        if let post = binaryposts.first,
           let take = takes.first(where: { $0.question == post.question }),
           let takeId = take.id {

            let selectedOption = responseOption == 1 ? post.responseOption1 : post.responseOption2
            let response = Response(
                responseId: UUID().uuidString,
                userId: userId,
                responseOption: selectedOption
            )
            post.responses.append(response)
            db.collection("TakeTime")
                .document(takeId)
                .collection("responses")
                .document(response.responseId)
                .setData([
                    "responseId": response.responseId,
                    "userId": response.userId,
                    "responseOption": response.responseOption
                ]) { error in
                    if let error = error {
                        print("Error writing response to Firestore: \(error)")
                    } else {
                        print("Response successfully written to Firestore")
                    }
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
    @State private var showBackgroundView = true
    @StateObject var takeVM = TakesVM()
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var userVM: UserFirebase
    @StateObject var scheduler: Scheduler

    var body: some View {
        if showBackgroundView {
            ZStack {
                SplashBackgroundView(colors: [.red, .red, .orange, .yellow, .red])
                    .ignoresSafeArea()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            withAnimation {
                                showBackgroundView = false
                            }
                        }
                    }
                SlidingWordsView(leftWord: "Take", rightWord: "Time")
                SymbolPopRotateView(symbolName: "hourglass")
            }
        } else {
            GeometryReader { geo in
                ZStack {
                    HStack {
                        RoundedRectangle(cornerRadius: 20.0)
                            .frame(
                                width: geo.size.width - 26
                                + (dragOffset.height > 0
                                   ? (dragOffset.height != 800.0
                                      ? min(dragOffset.height / 8, 8) : 8.0) : 0.0)
                            )
                            .overlay {
                                RoundedRectangle(cornerRadius: 20.0)
                                    .fill(Color.mediumGray)
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.black, lineWidth: 0.5)
                            )
                            .frame(
                                width: geo.size.width - 32
                                + (dragOffset.height > 0
                                   ? (dragOffset.height != 800.0
                                      ? min(dragOffset.height / 8, 8) : 8.0)
                                   : 0.0))
                    }

                    HStack {
                        RoundedRectangle(cornerRadius: 20.0)
                            .frame(
                                width: geo.size.width - 18
                                + (dragOffset.height > 0
                                   ? (dragOffset.height != 800.0
                                      ? min(dragOffset.height / 8, 12) : 12.0)
                                   : 0.0)
                            )
                            .overlay {
                                RoundedRectangle(cornerRadius: 20.0)
                                    .fill(Color.mediumGray)
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.black, lineWidth: 0.5)
                            )
                            .offset(
                                y: dragOffset.height > 0
                                ? (dragOffset.height != 800.0
                                   ? min(dragOffset.height / 10.0, 10.0)
                                   : 10.0) : 0.0)
                    }
                    .frame(
                        maxWidth: geo.size.width - 24
                        + (dragOffset.height > 0
                           ? (dragOffset.height != 800.0 ? min(dragOffset.height / 8, 12.0) : 12.0) : 0.0))

                    withAnimation(.none) {
                        HStack {
                            if takeVM.binaryposts.indices.contains(1),
                               let post = takeVM.binaryposts[1] as? BinaryPost {
                                TakeTimeBinaryPost(
                                    post: post,
                                    dragAmount: .constant(
                                        CGSize(width: 0.0, height: 0.0)),
                                    optionSelected: .constant(0),
                                    skipping: $hasSkipped
                                )
                                .background(
                                    RoundedRectangle(cornerRadius: 20.0)
                                        .fill(
                                            Color(
                                                red: (min(
                                                    255.0, 187.0 + dragOffset.height
                                                ) / 255),
                                                green: (min(
                                                    255.0, 187.0 + dragOffset.height
                                                ) / 255),
                                                blue: (min(
                                                    255.0, 187.0 + dragOffset.height
                                                ) / 255)))
                                )
                                .frame(
                                    width: max(
                                        0,
                                        geo.size.width - 6
                                        + (dragOffset.height > 0
                                           ? (dragOffset.height != 800.0
                                              ? min(
                                                dragOffset.height / 20.0,
                                                6.0) : 6.0) : 0.0))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(
                                            Color.black.opacity(
                                                hasSkipped
                                                ? 0.0
                                                : dragOffset.height > 0
                                                ? (dragOffset.height < 150.0
                                                   ? max(
                                                    100 - dragOffset
                                                        .height / 150.0,
                                                    0.0) : 0.0) : 1.0),
                                            lineWidth: 0.5)
                                )
                                .offset(
                                    y: 10
                                    + (dragOffset.height > 0
                                       ? (dragOffset.height != 800.0
                                          ? min(
                                            dragOffset.height / 10.0, 10.0)
                                          : 10.0) : 0.0)
                                )
                                .mask(
                                    RoundedRectangle(cornerRadius: 20.0).offset(
                                        y: 10))
                            }

                        }
                    }

                    VStack {
                        if let post = takeVM.binaryposts.first as? BinaryPost {
                            ZStack(alignment: .top) {
                                TakeTimeBinaryPost(
                                    post: post, dragAmount: $dragOffset,
                                    optionSelected: $optionSelected,
                                    skipping: $hasSkipped
                                )
                                .frame(width: max(0, geo.size.width))

                                if dragOffset.height > 0 {
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            .black.opacity(
                                                dragOffset.height / 100.0),
                                            .clear,
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
                                                .frame(
                                                    width: 30, height: 30,
                                                    alignment: .top
                                                )
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

                    .frame(
                        width: max(0, geo.size.width),
                        height: max(0, geo.size.height + 1000)
                    )
                    .background {
                        RoundedRectangle(cornerRadius: 20.0)
                            .fill(Color.white)
                    }
                    .rotatedBy(offset: $dragOffset, doAnimation: true)
                    .offset(y: dragOffset.height + 20)
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                withAnimation {
                                    if gesture.translation.height.magnitude
                                        > gesture.translation.width.magnitude
                                    {
                                        if !hasSkipped {
                                            dragOffset = CGSize(
                                                width: 0.0,
                                                height: gesture.translation.height)
                                        } else {
                                            withAnimation(.smooth(duration: 0.5)) {
                                                dragOffset = CGSize(
                                                    width: 0.0, height: 800.0)
                                            }
                                        }

                                        if dragOffset.height < -150 {
                                            if optionSelected != 0 {
                                                if let post = takeVM.binaryposts
                                                    .first
                                                {
                                                    if !isConfirmed
                                                        && optionSelected == 1
                                                    {
                                                        takeVM.addView(
                                                            responseOption:
                                                                optionSelected, userId: userVM.user.userId)
                                                    } else if !isConfirmed {
                                                        takeVM.addView(
                                                            responseOption:
                                                                optionSelected, userId: userVM.user.userId)
                                                    }
                                                    withAnimation {
                                                        isConfirmed = true
                                                    }
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
                                        if gesture.translation.width.magnitude > 150
                                        {
                                            dragOffset = .zero

                                            if gesture.translation.width > 0 {
                                                optionSelected = 2
                                                withAnimation {
                                                    isConfirmed = true
                                                }
                                                dragOffset = .zero
                                            } else {
                                                optionSelected = 1
                                                withAnimation {
                                                    isConfirmed = true
                                                }
                                                dragOffset = .zero
                                            }

                                        } else {
                                            dragOffset = .init(
                                                width: gesture.translation.width,
                                                height: 0.0)
                                        }
                                    }
                                }
                            }
                            .onEnded { gesture in

                                if let post = takeVM.binaryposts.first {
                                    if optionSelected != 0,
                                       let take = takeVM.takes.first(where: { $0.question == post.question }),
                                       let takeId = take.id {
                                        takeVM.addView(responseOption: optionSelected, userId: userVM.user.userId)
                                        takeVM.userResponses[takeId] = optionSelected
                                    }
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

                    if takeVM.binaryposts.isEmpty {
                        ZStack {
                            GeometryReader { _ in
                                    VStack {
                                        Text("Summary of your responses:")
                                            .font(.headline)
                                            .padding()
                                        ForEach(
                                            Array(takeVM.userResponses.enumerated()),
                                            id: \.offset
                                        ) { index, entry in
                                            let (id, selectedOption) = entry
                                            let question = takeVM.takes.first(where: { $0.id == id })?.question ?? "Unknown question"
                                            VStack(alignment: .leading, spacing: 8) {
                                                Text("Question \(index + 1)")
                                                    .font(.subheadline)
                                                    .fontWeight(.semibold)
                                                    .foregroundColor(.gray)
                                                Text(question)
                                                    .font(.body)
                                                    .foregroundColor(.primary)
                                                let choiceText = selectedOption == 1
                                                ? (takeVM.takes.first(where: { $0.id == id })?.responseOption1 ?? "Option 1")
                                                : (takeVM.takes.first(where: { $0.id == id })?.responseOption2 ?? "Option 2")

                                                Text("Your choice: \(choiceText)")
                                                    .font(.footnote)
                                                    .foregroundColor(.blue)
                                                Divider()
                                            }
                                            .padding(.vertical, 6)
                                        }
                                        Spacer()
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .background(Color.white)
                                }
                        }
                        .contentShape(Rectangle())
                        .allowsHitTesting(true)
                        .gesture(
                            DragGesture().onEnded { value in
                                if value.translation.height > 100 {
                                    scheduler.shouldInterrupt = false
                                    dismiss()
                                }
                            }
                        )
                    }
                }
                .onAppear {
                    userVM.user.myTakeTime = [:]
                    userVM.updateUserFields(user: userVM.user)
                }
                .frame(width: min(geo.size.width, UIScreen.main.bounds.width))
                .background(.black)
            }
            .onChange(of: takeVM.binaryposts.isEmpty) {
                if takeVM.binaryposts.isEmpty {
                    userVM.user.myTakeTime = takeVM.userResponses
                    userVM.updateUserFields(user: userVM.user)
                }
            }
        }
    }
}

struct SymbolPopRotateView: View {
    let symbolName: String
    @State private var animate = false

    var body: some View {
        VStack {
            Spacer()
            Image(systemName: symbolName)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .scaleEffect(animate ? 1.5 : 1.0)
                .rotationEffect(.degrees(animate ? 45 : 0))
                .animation(.easeInOut(duration: 1.0), value: animate)
                .opacity(0.5)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            animate = true
        }
    }
}

#Preview {
    TakeTimeTakesView(scheduler: Scheduler())
            .environmentObject(UserFirebase())
    //        .environmentObject(PostFirebase())
}
