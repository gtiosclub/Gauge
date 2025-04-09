//
//  TakeMasterView.swift
//  Gauge
//
//  Created by Akshat Shenoi on 4/7/25.
//

import SwiftUI
import simd

#Preview {
    ZStack {
        SplashBackgroundView()
        SlidingWordsView(leftWord: "Ready for", rightWord: "Results?")
    }
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
                        SlidingWordsView(leftWord: transitionWords().0, rightWord: transitionWords().1)
                    }
                } else {
                    switch manager.phase {
                    case .questionSelect:
                        QuestionSelectView(manager: manager)
                    case .waitingForQuestions:
                        ZStack {
                            SplashBackgroundView()
                            LoadingView(message: "Waiting for everyone to submit their questions...")
                        }
                    case .roundStart:
                        RoundStartView(manager: manager)
                    case .waitingForAnswers:
                        ZStack {
                            SplashBackgroundView()
                            LoadingView(message: "Waiting for everyone to answer the question...")
                        }
                    case .guessPhase:
                        GuessView(manager: manager)
                    case .waitingForGuesses:
                            ZStack {
                                SplashBackgroundView()
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
            Text("Create a Question and Answer it based on how you feel!")
                .font(.title)
                .multilineTextAlignment(.center)
            TextField("Question:", text: $question, axis: .vertical)
                .font(.title)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .multilineTextAlignment(.leading)
                .lineLimit(2, reservesSpace: true)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.black)
                        .stroke(Color.white)
                )
            TextField("Answer:", text: $answer, axis: .vertical)
                .font(.title)
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .multilineTextAlignment(.leading)
                .lineLimit(2, reservesSpace: true)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .stroke(Color.black)
                )
            Button(action: {
                manager.submitQuestion(question, answer: answer, from: manager.username)
            }) {
                Text("Submit")
                    .font(.title2)
                    .foregroundColor(.black)
                    .padding()
                    .background(Color(.secondarySystemFill))
                    .cornerRadius(12)
                    .scaleEffect(1.0)
            }
            .frame(maxWidth: 400)
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
                Text("The Take Master is \(currentQuestion.playerID)")
                    .font(.title)
                Text(currentQuestion.question)
                    .font(.title)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.black)
                            .stroke(Color.white)
                    )
                if (currentQuestion.playerID != manager.username) {
                    TextField("Answer:", text: $answer, axis: .vertical)
                        .font(.title)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2, reservesSpace: true)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
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
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white)
                                .stroke(Color.black)
                        )
                }
                Button(action: {
                    if (manager.username == currentQuestion.playerID) {
                        answer = currentQuestion.answer
                    }
                        manager.submitRoundAnswer(answer, from: manager.username)
                }) {
                    Text("Submit")
                        .font(.title2)
                        .foregroundColor(.black)
                        .padding()
                        .background(Color(.secondarySystemFill))
                        .cornerRadius(12)
                        .scaleEffect(1.0)
                }
                .frame(maxWidth: 400)
                .buttonStyle(PressEffectButtonStyle())
            }
        }
        .padding()
    }
}

struct GuessView: View {
    @ObservedObject var manager: TMManager

    var body: some View {
        VStack {
            Text("Guess which answer is the original!")
                .font(.headline)
            ForEach(manager.roundAnswers, id: \.playerID) { submission in
                Button(submission.answer) {
                    manager.submitGuess(submission.answer, from: manager.username)
                }
            }
        }
        .padding()
    }
}

struct TMResultsView: View {
    @ObservedObject var manager: TMManager

    var body: some View {
        VStack {
            Text("Results of this round")
                .font(.headline)
            ForEach(manager.roundGuesses, id: \.playerID) { submission in
                Text("\(submission.playerID): \(submission.answer == manager.currentQuestion?.answer ? "Correct" : "Incorrect")")
            }
            // You can expand this area to show detailed results
            Button("Next Round") {
                manager.resetGame()
            }
        }
        .padding()
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
                        .animation(.easeOut(duration: 1.0), value: animate)
                    Spacer()
                }
                .offset(x: animate ? 200 : -geometry.size.width)

                HStack {
                    Spacer()
                    Text(rightWord)
                        .font(.system(size: 64, weight: .bold))
                        .opacity(0.5)
                        .animation(.easeOut(duration: 1.0), value: animate)
                }
                .offset(x: animate ? -200 : geometry.size.width)
            }
            .padding(.horizontal)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            animate = true
        }
    }
}

@available(iOS 17.0, *)
struct SplashBackgroundView: View {
    @State private var angles: [Double] = [0, 72, 144, 216, 288]

    var body: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            let updatedAngles = angles.enumerated().map { index, base in
                base + t * 100 + Double(index) * 15 // Different speeds
            }

            ZStack {
                RotatingBlob(color: .yellow, angle: updatedAngles[0], radius: 250)
                RotatingBlob(color: .cyan, angle: updatedAngles[1], radius: 250)
                RotatingBlob(color: .purple, angle: updatedAngles[2], radius: 250)
                RotatingBlob(color: .blue, angle: updatedAngles[3], radius: 200)
                RotatingBlob(color: .mint, angle: updatedAngles[4], radius: 250)
            }
            .blur(radius: 60)
            .ignoresSafeArea()
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
