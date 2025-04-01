import SwiftUI

struct VotingProgressView: View {
    @ObservedObject var mcManager: MCManager
    @ObservedObject var gameSettings = TakeMatchSettingsVM.shared
    @State private var isTabulatingVotes = false
    @State private var navigateToQuestionView = false
    @State private var inputText: String = ""

    var allVotesReceived: Bool {
        return mcManager.votes.values.reduce(0, +) >= mcManager.session.connectedPeers.count + 1
    }

    var voteProgress: Double {
        let totalVotes = mcManager.votes.values.reduce(0, +)
        return Double(totalVotes) / Double(mcManager.session.connectedPeers.count + 1)
    }

    var body: some View {
        NavigationStack {
            VStack {
                //Text("\(mcManager.votes)")
                Text("Nice! Let's wait and see what everyone voted for.")
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .padding()
                ProgressView("Waiting...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()

                ProgressView(value: voteProgress, total: 1.0)
                    .progressViewStyle(LinearProgressViewStyle())
                    .padding()

                Text("\(mcManager.votes.values.reduce(0, +))/\(mcManager.session.connectedPeers.count + 1)")





                NavigationLink(
                    destination: QuestionView(
                        mcManager: mcManager,
                        question: gameSettings.question,
                        inputText: $inputText,
                        onSubmit: {mcManager.submitAnswer(inputText)}
                    ),
                    isActive: $navigateToQuestionView
                ) {
                    EmptyView()
                }
            }
            .onAppear() {
                if allVotesReceived {
                    tabulateVotes()
                }
            }
            .onChange(of: allVotesReceived) {
                if allVotesReceived {
                    if (!gameSettings.question.isEmpty) {
                        navigateToQuestionView = true
                    }
                }
            }
            .onChange(of: gameSettings.question) {
                navigateToQuestionView = true
            }
//            .onAppear() {
//                if allVotesReceived {
//                    //tabulateVotes()
//                    navigateToQuestionView = true
//                }
//            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
    }

    // Function to call tabulateVotes once all votes are in
    private func tabulateVotes() {
        isTabulatingVotes = true
        mcManager.tabulateVotes()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isTabulatingVotes = false
        }
    }
}

struct VotingProgressView_Previews: PreviewProvider {
    static var previews: some View {
        VotingProgressView(mcManager: MCManager(yourName: "test"))
    }
}
