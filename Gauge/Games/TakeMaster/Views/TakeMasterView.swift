//
//  TakeMasterView.swift
//  Gauge
//
//  Created by Akshat Shenoi on 4/7/25.
//

import SwiftUI
import simd
import UniformTypeIdentifiers
import MultipeerConnectivity

#Preview {
//    ZStack {
//        SplashBackgroundView()
//        SlidingWordsView(leftWord: "Ready for", rightWord: "Results?")
//    }
    QuestionSelectView(manager: TMManager(yourName: "Akshat", isHost: "Y"))
}

struct TakeMasterView: View {
    @ObservedObject var manager: TMManager
    @State var navigateBack = false
    @State private var showTransition = false

    var body: some View {
        NavigationStack {
            VStack {
                if showTransition {
                    ZStack {
                        SplashBackgroundView()
                            .ignoresSafeArea()
                        SlidingWordsView(leftWord: transitionWords().0, rightWord: transitionWords().1)
                    }
                } else {
                    switch manager.phase {
                    case .questionSelect:
                        QuestionSelectView(manager: manager)
                    case .waitingForQuestions:
                        ZStack {
                            SplashBackgroundView()
                                .ignoresSafeArea()
                            LoadingView(message: "Waiting for everyone to submit their questions...")
                        }
                    case .roundStart:
                        RoundStartView(manager: manager)
                    case .waitingForAnswers:
                        ZStack {
                            SplashBackgroundView()
                                .ignoresSafeArea()
                            LoadingView(message: "Waiting for everyone to answer the question...")
                        }
                    case .guessPhase:
                        GuessView(manager: manager)
                    case .waitingForGuesses:
                            ZStack {
                                SplashBackgroundView()
                                    .ignoresSafeArea()
                                LoadingView(message: "Waiting for everyone to guess...")
                            }
                    case .results:
                        TMResultsView(manager: manager)
                    case .notStarted:
                        EmptyView()
                    }
                }
            }
        }
        .navigationTitle(Text("Take Master"))
        .background(Color.white)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            manager.phase = .notStarted
                            manager.resetGame()
                            manager.gameStarted = false
                            navigateBack.toggle()
                        }
                    }
                }) {
                    Image(systemName: "arrow.left")
                        .foregroundColor(.black)
                }
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .navigationDestination(isPresented: $navigateBack) {
            TakeMasterRoomView(tmManager: manager, roomCode: manager.roomCode, onExit: {})
        }
        .onChange(of: manager.phase) { _ in
            if (manager.phase == .roundStart || manager.phase == .guessPhase || manager.phase == .results) {
                showTransition = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    showTransition = false
                }
            }

        }
    }

    private func transitionWords() -> (String, String) {
        switch manager.phase {
        case .questionSelect:
            return ("", "")
        case .waitingForQuestions:
            return ("", "")
        case .roundStart:
            return ("Round", "Start")
        case .waitingForAnswers:
            return ("", "")
        case .guessPhase:
            return ("Guessing", "Time")
        case .waitingForGuesses:
            return ("", "")
        case .results:
            return ("Ready for", "Results?")
        case .notStarted:
            return ("", "")
        }
    }

}

struct QuestionSelectView: View {
    @ObservedObject var manager: TMManager
    @State private var question: String = ""
    @State private var answer: String = ""

    var body: some View {
        VStack {
            Text("Create a Question for when you're the Take Master!")
                .font(.title)
                .multilineTextAlignment(.center)
            ZStack {
                if question.isEmpty {
                    Text("Make a question...")
                        .font(.title)
                        .foregroundStyle(.gray)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2, reservesSpace: true)
                        .padding()
                }
                TextField("", text: $question, axis: .vertical)
                    .font(.title)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2, reservesSpace: true)
                    .padding()

            }
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.black)
            )
            TextField("Answer your question...", text: $answer, axis: .vertical)
                .font(.title)
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .multilineTextAlignment(.leading)
                .lineLimit(2, reservesSpace: true)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white)
                        .stroke(Color.black)
                )
            Button(action: {
                manager.submitQuestion(question, answer: answer.lowercased(), from: manager.myPeerID.displayName)
            }) {
                Text("Submit")
                    .foregroundColor(.white)
                    .padding(.horizontal, 50)
                    .padding(.vertical, 10)
                    .background(Color(.black))
                    .cornerRadius(12)
                    .scaleEffect(1.0)
                    .font(.system(size: 32, weight: .medium))
            }
            .buttonStyle(PressEffectButtonStyle())
        }
        .padding()
    }
}

struct RoundStartView: View {
    @ObservedObject var manager: TMManager
    @State private var answer: String = ""
    @State private var currentQuestion: String = ""

    var body: some View {
        VStack {
            if let currentQuestion = manager.currentQuestion {
                if let peer = manager.connectedPeers.first(where: { $0.displayName == currentQuestion.playerID }) {
                    Text("The Take Master is \(manager.discoveredPeers[peer]?.username ?? "")")
                        .font(.title)
                }
                Text(currentQuestion.question)
                    .font(.title)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.black)
                    )
                if (currentQuestion.playerID != manager.myPeerID.displayName) {
                    TextField("Answer:", text: $answer, axis: .vertical)
                        .font(.title)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2, reservesSpace: true)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white)
                                .stroke(Color.black)
                        )
                } else {
                    Text("\(currentQuestion.answer)")
                        .font(.title)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2, reservesSpace: true)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white)
                                .stroke(Color.black)
                        )
                }
                Button(action: {
                    if (manager.myPeerID.displayName == currentQuestion.playerID) {
                        answer = currentQuestion.answer
                    }
                    manager.submitRoundAnswer(answer, from: manager.myPeerID.displayName)
                }) {
                    Text("Submit")
                        .foregroundColor(.white)
                        .padding(.horizontal, 50)
                        .padding(.vertical, 10)
                        .background(Color(.black))
                        .cornerRadius(12)
                        .scaleEffect(1.0)
                        .font(.system(size: 32, weight: .medium))
                }
                .buttonStyle(PressEffectButtonStyle())
            }
        }
        .padding()
    }
}

struct GuessView: View {
    @ObservedObject var manager: TMManager
    @State private var draggedAnswerID: String? = nil
    @GestureState private var dragOffset = CGSize.zero
    @EnvironmentObject private var userVm: UserFirebase
    @State var profilePhoto: String = ""
    @State var profileRadius = 65.0

    var body: some View {
        VStack(spacing: 15) {
            if let currentQuestion = manager.currentQuestion {
                if let peer = manager.connectedPeers.first(where: { $0.displayName == currentQuestion.playerID }) {
                    Text(currentQuestion.question)
                        .font(.title)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.black)
                        )
                    Text("Match \(manager.discoveredPeers[peer]?.username ?? "") to their answer.")
                        .font(.headline)
                } else if (currentQuestion.playerID == manager.myPeerID.displayName) {
                    Text(currentQuestion.question)
                        .font(.title)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.black)
                        )
                    Text("Match \(manager.username) to their answer.")
                        .font(.headline)
                }
            }


            ScrollView {
                VStack(spacing: 10) {
                    ForEach(manager.roundAnswers, id: \.playerID) { submission in
                        HStack(alignment: .center, spacing: 20) {
                        Spacer()
                            if draggedAnswerID == submission.playerID {
                                ZStack {
                                    if profilePhoto != "", let url = URL(string: profilePhoto) {
                                        AsyncImage(url: url) { phase in
                                            switch phase {
                                            case .success(let image):
                                                image
                                                    .resizable()
                                                    .frame(width: profileRadius, height: profileRadius)
                                                    .clipShape(Circle())
                                            case .failure, .empty:
                                                Image(systemName: "person.circle.fill")
                                                    .resizable()
                                                    .frame(width: profileRadius, height: profileRadius)
                                                    .foregroundColor(.black)
                                            @unknown default:
                                                EmptyView()
                                            }
                                        }
                                        .contentShape(.dragPreview, Circle())
                                        .scaledToFit()
                                        .frame(width: profileRadius, height: profileRadius)
                                        .clipped()
                                        .foregroundColor(.black)
                                        .draggable(manager.username)
                                    }
                                    Circle()
                                        .strokeBorder(
                                            style: StrokeStyle(
                                                lineWidth: 3
                                            )
                                        )
                                        .foregroundColor(Color(red: 248/255, green: 192/255, blue: 21/255))
                                        .frame(width: profileRadius, height: profileRadius)
                                }
                            }

                            Text(submission.answer)
                                .font(.system(size: 25, weight: .medium))
                                .padding(20)
                                .foregroundColor(.black)
                                .background(Color(red: 235/255, green: 235/255, blue: 235/255))
                                .cornerRadius(50)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .animation(.easeOut(duration: 0.3), value: draggedAnswerID)
                        }
                        .dropDestination(for: String.self) { items, location in
                            if let _ = items.first {
                                draggedAnswerID = submission.playerID
                                return true
                            }
                            return false
                        }
                    }
                }
            }
            .padding(.horizontal, -25)

            Spacer()

            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: profileRadius + 12, height: profileRadius + 12)
                    .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)

                if profilePhoto != "", let url = URL(string: profilePhoto) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .frame(width: profileRadius, height: profileRadius)
                                .clipShape(Circle())
                        case .failure, .empty:
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: profileRadius, height: profileRadius)
                                .foregroundColor(.black)
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .contentShape(.dragPreview, Circle())
                    .scaledToFit()
                    .frame(width: profileRadius, height: profileRadius)
                    .clipped()
                    .foregroundColor(.black)
                    .draggable(manager.username)
                }

                Circle()
                    .strokeBorder(
                        style: StrokeStyle(
                            lineWidth: 3,
                            dash: draggedAnswerID != nil ? [6, 4] : []
                        )
                    )
                    .foregroundColor(Color(red: 248/255, green: 192/255, blue: 21/255))
                    .frame(width: profileRadius, height: profileRadius)
            }
            .opacity(draggedAnswerID != nil ? 0.5 : 1.0)

            Button(action: {
                if (manager.currentQuestion?.playerID != manager.myPeerID.displayName) {
                    if let id = draggedAnswerID,
                       let answer = manager.roundAnswers.first(where: { $0.playerID == id })?.answer {
                        manager.submitGuess(answer, from: manager.myPeerID.displayName)
                    }
                }
            }) {
                Text("Submit")
                    .foregroundColor(.white)
                    .padding(.horizontal, 50)
                    .padding(.vertical, 10)
                    .background(Color(.black))
                    .cornerRadius(12)
                    .scaleEffect(1.0)
                    .font(.system(size: 32, weight: .medium))
            }
            .buttonStyle(PressEffectButtonStyle())
            .disabled(draggedAnswerID == nil)
        }
        .onAppear {
            if let peer = manager.connectedPeers.first(where: { $0.displayName == manager.currentQuestion?.playerID }) {
                if let userId = manager.discoveredPeers[peer]?.profileLink {
                   fetchUserInfo(userID: userId)
                }
            } else if manager.currentQuestion?.playerID == manager.myPeerID.displayName {
                manager.submitGuess(manager.currentQuestion?.answer ?? "", from: manager.myPeerID.displayName)
                fetchUserInfo(userID: manager.profileLink)
            }
        }
        .padding(25)
    }

    func fetchUserInfo(userID: String) {
        userVm.getUsernameAndPhoto(userId: userID) { info in
            DispatchQueue.main.async {
                profilePhoto = info["profilePhoto"] ?? ""
            }
        }
    }
}

struct TMResultsView: View {
    @ObservedObject var manager: TMManager
    @EnvironmentObject private var userVm: UserFirebase
    @State private var userInfoMap: [MCPeerID: (username: String, profilePhoto: String)] = [:]
    @State private var fetchedPeers: Set<MCPeerID> = []
    @State private var profilePhotoSize = 65.0
    @State private var myProfilePhoto = ""

    func fetchUserInfo(for peer: MCPeerID, userID: String) {
        userVm.getUsernameAndPhoto(userId: userID) { info in
            DispatchQueue.main.async {
                userInfoMap[peer] = (
                    info["username"] ?? "",
                    info["profilePhoto"] ?? ""
                )
            }
        }
    }

    var body: some View {
        VStack(spacing: 15) {
            if let currentQuestion = manager.currentQuestion {
                if let peer = manager.connectedPeers.first(where: { $0.displayName == currentQuestion.playerID }) {
                    Text(currentQuestion.question)
                        .font(.title)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.black)
                        )
                } else if (currentQuestion.playerID == manager.myPeerID.displayName) {
                    Text(currentQuestion.question)
                        .font(.title)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.black)
                        )
                }
                Text("Results of this round")
                    .font(.headline)
            }

            let groupedGuesses = Dictionary(grouping: manager.roundGuesses, by: { $0.answer })

            VStack(spacing: 10) {
                ForEach(manager.roundAnswers, id: \.playerID) { answerSubmission in
                    HStack {
                        if let votes = groupedGuesses[answerSubmission.answer] {
                            ZStack {
                                ForEach(Array(votes.enumerated()), id: \.1.playerID) { index, guess in
                                    if let peer = manager.connectedPeers.first(where: { $0.displayName == guess.playerID }) {
                                        if let userId = manager.discoveredPeers[peer]?.profileLink {
                                            Color.clear
                                                .frame(width: 0, height: 0)
                                                .onAppear {
                                                    if !fetchedPeers.contains(peer) {
                                                        fetchUserInfo(for: peer, userID: userId)
                                                        fetchedPeers.insert(peer)
                                                    }
                                                }
                                        }
                                        if let profilePhoto = userInfoMap[peer]?.profilePhoto, let url = URL(string: profilePhoto) {
                                            AsyncImage(url: url) { phase in
                                                switch phase {
                                                case .success(let image):
                                                    image
                                                        .resizable()
                                                        .frame(width: profilePhotoSize, height: profilePhotoSize)
                                                        .clipShape(Circle())
                                                case .failure, .empty:
                                                    Image(systemName: "person.circle.fill")
                                                        .resizable()
                                                        .frame(width: profilePhotoSize, height: profilePhotoSize)
                                                        .foregroundColor(.gray)
                                                @unknown default:
                                                    EmptyView()
                                                }
                                            }
                                            .offset(x: CGFloat(index) * 20)
                                        }
                                    } else if guess.playerID == manager.myPeerID.displayName {
                                        if let profilePhoto = userInfoMap[manager.myPeerID]?.profilePhoto, let url = URL(string: profilePhoto) {
                                            AsyncImage(url: url) { phase in
                                                switch phase {
                                                case .success(let image):
                                                    image
                                                        .resizable()
                                                        .frame(width: profilePhotoSize, height: profilePhotoSize)
                                                        .clipShape(Circle())
                                                case .failure, .empty:
                                                    Image(systemName: "person.circle.fill")
                                                        .resizable()
                                                        .frame(width: profilePhotoSize, height: profilePhotoSize)
                                                        .foregroundColor(.gray)
                                                @unknown default:
                                                    EmptyView()
                                                }
                                            }
                                            .offset(x: CGFloat(index) * 20)
                                        }
                                    }
                                }
                            }
                            .onAppear {
                                if !fetchedPeers.contains(manager.myPeerID) {
                                    fetchUserInfo(for: manager.myPeerID, userID: manager.profileLink)
                                    fetchedPeers.insert(manager.myPeerID)
                                }
                            }
                            .padding(.trailing)
                        }

                        Text(answerSubmission.answer)
                            .font(.system(size: 25, weight: .medium))
                            .padding(20)
                            .foregroundColor(.black)
                            .background(manager.currentQuestion?.answer == answerSubmission.answer ? Color(red: 174/255, green: 234/255, blue: 189/255) : Color(red: 241/255, green: 186/255, blue: 186/255))
                            .cornerRadius(50)
                        Spacer()
                    }
                }
                Spacer()
                Button("Leave") {
                    manager.resetGame()
                }
            }
        }
        .padding(25)
    }
}

struct LoadingView: View {
    var message: String

    var body: some View {
        VStack {
            ProgressView()
            Text(message)
                .padding()
        }
    }
}

struct SlidingWordsView: View {
    let leftWord: String
    let rightWord: String

    @State private var animate = false

    var body: some View {
        GeometryReader { geometry in
            VStack {
                HStack {
                    Text(leftWord)
                        .font(.system(size: 64, weight: .bold))
                        .opacity(0.5)
                        .offset(x: animate ? 0 : -geometry.size.width)
                        .animation(.easeOut(duration: 1.0), value: animate)
                    Spacer()
                }

                HStack {
                    Spacer()
                    Text(rightWord)
                        .font(.system(size: 64, weight: .bold))
                        .opacity(0.5)
                        .offset(x: animate ? 0 : geometry.size.width)
                        .animation(.easeOut(duration: 1.0), value: animate)
                }
            }
            .padding(.horizontal)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            animate = true
        }
    }
}

struct SplashBackgroundView: View {
    var colors: [Color]? = nil
    @State private var angles: [Double] = [0, 72, 144, 216, 288]

    var body: some View {
        GeometryReader { geometry in
            TimelineView(.animation) { timeline in
                let t = timeline.date.timeIntervalSinceReferenceDate
                let updatedAngles = angles.enumerated().map { index, base in
                    base + t * 100 + Double(index) * 15
                }

                ZStack {
                    ForEach(0..<angles.count, id: \.self) { i in
                        RotatingBlob(
                            color: blobColor(index: i),
                            angle: updatedAngles[i],
                            radius: min(geometry.size.width, geometry.size.height) / 2.2
                        )
                    }
                }
                .blur(radius: 40)
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
        .ignoresSafeArea()
        .clipped()
    }

    private func blobColor(index: Int) -> Color {
        let defaultColors: [Color] = [.yellow, .cyan, .purple, .blue, .mint]
        let colorList = colors ?? defaultColors
        if index < colorList.count {
            return colorList[index]
        } else {
            return .gray
        }
    }
}

struct RotatingBlob: View {
    var color: Color
    var angle: Double
    var radius: CGFloat

    var body: some View {
        let radians = angle * .pi / 180
        let x = cos(radians) * radius
        let y = sin(radians) * radius

        return RadialGradient(gradient: Gradient(colors: [color.opacity(0.6), .clear]),
                              center: .center,
                              startRadius: 0,
                              endRadius: 600)
            .frame(width: 800, height: 800)
            .offset(x: x, y: y)
    }
}

//#Preview {
//    QuestionSelectView(manager: TMManager(yourName: "test", isHost: "Y"))
//}
