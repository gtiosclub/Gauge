import MultipeerConnectivity

class TMManager: NSObject, ObservableObject {

    private let serviceType = String.serviceName
    private var session: MCSession
    var myPeerID: MCPeerID
    private var nearbyServiceAdvertiser: MCNearbyServiceAdvertiser
    private let nearbyServiceBrowser: MCNearbyServiceBrowser

    @Published var username: String
    @Published var profileLink: String
    @Published var isHost: String
    @Published var roomCode: String
    @Published var connectedPeers: [MCPeerID] = []
    @Published var discoveredPeers: [MCPeerID: AdvertisedInfo] = [:]
    @Published var receivedInvite: Bool = false
    @Published var receivedInviteFrom: MCPeerID?
    @Published var invitationHandler: ((Bool, MCSession?) -> Void)?
    @Published var paired: Bool = false
    @Published var gameStarted: Bool = false
    @Published var isAvailableToPlay: Bool = false {
        didSet {
            isAvailableToPlay ? startAdvertising() : stopAdvertising()
        }
    }

    @Published var phase: GamePhase = .notStarted
    @Published var questionSubmissions: [PlayerSubmission] = []
    @Published var currentQuestion: PlayerSubmission? = nil
    @Published var roundAnswers: [PlayerSubmission] = []
    @Published var roundGuesses: [PlayerSubmission] = []

    var expectedPlayers: Int { connectedPeers.count + 1 }

    var openRoomsCount: Int {
        return Set(discoveredPeers.values.compactMap { $0.roomCode }).count - 1
    }

    init(yourName: String, isHost: String) {
        self.username = yourName
        self.profileLink = "TestProfile"
        self.isHost = isHost
        self.roomCode = ""

        self.myPeerID = MCPeerID(displayName: yourName)
        self.session = MCSession(peer: myPeerID)
        self.nearbyServiceAdvertiser = MCNearbyServiceAdvertiser(
            peer: myPeerID,
            discoveryInfo: nil,
            serviceType: serviceType
        )
        self.nearbyServiceBrowser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: serviceType)
        super.init()
        session.delegate = self
        nearbyServiceAdvertiser.delegate = self
        nearbyServiceBrowser.delegate = self
    }

    deinit {
        stopBrowsing()
        stopAdvertising()
    }

    // MARK: - Advertising and Browsing
    func startAdvertising() {
        nearbyServiceAdvertiser.startAdvertisingPeer()
    }

    func stopAdvertising() {
        nearbyServiceAdvertiser.stopAdvertisingPeer()
    }

    func startBrowsing() {
        nearbyServiceBrowser.startBrowsingForPeers()
    }

    func stopBrowsing() {
        nearbyServiceBrowser.stopBrowsingForPeers()
        discoveredPeers.removeAll()
    }

    // MARK: - User Info Updates
    func setUsernameAndProfile(username: String, profileLink: String, isHost: String) {
        self.username = username
        self.isHost = isHost
        self.profileLink = profileLink
        nearbyServiceAdvertiser.stopAdvertisingPeer()
        let discoveryInfo: [String: String] = ["isHost": isHost, "username": username, "profileLink": profileLink]
        nearbyServiceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: discoveryInfo, serviceType: serviceType)
        nearbyServiceAdvertiser.delegate = self
        startAdvertising()
    }

    // MARK: - Room Management
    func startHosting(with roomCode: String) {
        stopAdvertising()
        self.roomCode = roomCode
        let discoveryInfo: [String: String] = ["isHost": isHost, "roomCode": roomCode, "username": username, "profileLink": profileLink]
        nearbyServiceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: discoveryInfo, serviceType: serviceType)
        nearbyServiceAdvertiser.delegate = self
        startAdvertising()
    }

    func joinRoom(with code: String) {
        if let targetPeer = discoveredPeers.first(where: { $0.value.roomCode == code })?.key {
            nearbyServiceBrowser.invitePeer(targetPeer, to: session, withContext: nil, timeout: 10)
        } else {
            print("No host found with room code: \(code)")
        }
    }

    func broadcastStartGame() {
        let message: [String: String] = ["type": "startGame"]

        if let data = try? JSONSerialization.data(withJSONObject: message, options: []) {
            do {
                try session.send(data, toPeers: session.connectedPeers, with: .reliable)
                print("📤 Sent 'startGame' message to: \(connectedPeers.map(\.displayName))")
            } catch {
                print("❌ Error sending start game message: \(error)")
            }
        }
    }

    func broadcastRoundStart(_ submission: PlayerSubmission) {
        let payload: [String: String] = [
            "type": "roundStart",
            "question": submission.question,
            "answer": submission.answer,
            "author": submission.playerID
        ]

        if let data = try? JSONSerialization.data(withJSONObject: payload, options: []) {
            try? session.send(data, toPeers: session.connectedPeers, with: .reliable)
        }
    }

    func broadcastGuessStart() {
        let payload: [String: String] = [
            "type": "guessStart"
        ]
        if let data = try? JSONSerialization.data(withJSONObject: payload, options: []) {
            try? session.send(data, toPeers: session.connectedPeers, with: .reliable)
        }
    }
    func broadcastResultsStart() {
        let payload: [String: String] = [
            "type": "resultsStart"
        ]
        if let data = try? JSONSerialization.data(withJSONObject: payload, options: []) {
            try? session.send(data, toPeers: session.connectedPeers, with: .reliable)
        }
    }

    func broadcastQuestionSubmission(_ submission: PlayerSubmission) {
        let payload: [String: String] = [
            "type": "questionSubmission",
            "question": submission.question,
            "answer": submission.answer,
            "author": submission.playerID
        ]
        if let data = try? JSONSerialization.data(withJSONObject: payload, options: []) {
            try? session.send(data, toPeers: session.connectedPeers, with: .reliable)
        }
    }

    func broadcastAnswerSubmission(_ submission: PlayerSubmission) {
        let payload: [String: String] = [
            "type": "roundAnswer",
            "answer": submission.answer,
            "author": submission.playerID
        ]
        if let data = try? JSONSerialization.data(withJSONObject: payload, options: []) {
            try? session.send(data, toPeers: session.connectedPeers, with: .reliable)
        }
    }
    func broadcastGuessSubmission(_ submission: PlayerSubmission) {
        let payload: [String: String] = [
            "type": "roundGuess",
            "answer": submission.answer,
            "author": submission.playerID
        ]
        if let data = try? JSONSerialization.data(withJSONObject: payload, options: []) {
            try? session.send(data, toPeers: session.connectedPeers, with: .reliable)
        }
    }

    func deleteRoom() {
        stopAdvertising()
        resetGame()
        stopBrowsing()
        paired = false
        gameStarted = false
        receivedInvite = false
        receivedInviteFrom = nil
        invitationHandler = nil
        discoveredPeers.removeAll()
        print("Room deleted.")
    }

    func disconnectFromSession() {
        isHost = "N"
        session.disconnect()
        session.delegate = nil
        session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .none)
        stopAdvertising()
        stopBrowsing()
        connectedPeers.removeAll()
        print("Disconnected from session.")
    }

    func submitQuestion(_ question: String, answer: String, from playerID: String) {
        let submission = PlayerSubmission(playerID: playerID, question: question, answer: answer)
        questionSubmissions.append(submission)
        if questionSubmissions.count >= expectedPlayers {
            broadcastQuestionSubmission(submission)
        } else {
            broadcastQuestionSubmission(submission)
            phase = .waitingForQuestions
        }
    }

    func submitRoundAnswer(_ answer: String, from playerID: String) {
        let submission = PlayerSubmission(playerID: playerID, question: "", answer: answer)
        roundAnswers.append(submission)
        if roundAnswers.count >= expectedPlayers {
            broadcastAnswerSubmission(submission)
        } else {
            broadcastAnswerSubmission(submission)
            phase = .waitingForAnswers
        }
    }

    func submitGuess(_ guess: String, from playerID: String) {
        let submission = PlayerSubmission(playerID: playerID, question: "", answer: guess)
        roundGuesses.append(submission)
        if roundGuesses.count >= expectedPlayers {
            broadcastGuessSubmission(submission)
        } else {
            broadcastGuessSubmission(submission)
            phase = .waitingForGuesses
        }
    }

    func resetGame() {
        questionSubmissions = []
        roundAnswers = []
        roundGuesses = []
        currentQuestion = nil
        phase = .notStarted
    }
}

extension TMManager: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        if (peerID != myPeerID) {
            DispatchQueue.main.async {
                let roomCode = info?["roomCode"]
                let username = info?["username"] ?? "bug"
                let profileLink = info?["profileLink"] ?? "TestProfile"
                let isHost = info?["isHost"]
                let advertisedInfo = AdvertisedInfo(isHost: isHost ?? "N", roomCode: roomCode ?? "", username: username, profileLink: profileLink)
                self.discoveredPeers[peerID] = advertisedInfo
                print("Open rooms: \(self.openRoomsCount)")
            }
        }
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        DispatchQueue.main.async {
            if (peerID != self.myPeerID) {
                self.discoveredPeers.removeValue(forKey: peerID)
            }
        }
    }
}

extension TMManager: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        DispatchQueue.main.async {
            self.receivedInvite = true
            self.receivedInviteFrom = peerID
            self.invitationHandler = invitationHandler
            invitationHandler(true, self.session)
        }
    }
}

extension TMManager: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            self.connectedPeers = session.connectedPeers

            switch state {
            case .connected:
                self.paired = true
                self.isAvailableToPlay = true
                print("State changed: \(peerID.displayName) is now connected")
                print("Current connectedPeers: \(session.connectedPeers.map(\.displayName))")

            case .notConnected:
                print("State changed: \(peerID.displayName) is now not connected")
                print("Current connectedPeers: \(session.connectedPeers.map(\.displayName))")
                self.paired = false
                self.isAvailableToPlay = true
                if self.connectedPeers.isEmpty {
                    print("All peers disconnected. Stopping room.")
                    self.deleteRoom()
                }

            default:
                print("State changed: \(peerID.displayName) is now \(state)")
                print("Current connectedPeers: \(session.connectedPeers.map(\.displayName))")
                break
            }
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        guard let message = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: String],
              let type = message["type"] else { return }

        DispatchQueue.main.async {
            switch type {
            case "startGame":
                self.gameStarted = true
                self.phase = .questionSelect
            case "roundStart":
                if let question = message["question"],
                   let answer = message["answer"],
                   let author = message["author"] {
                    self.currentQuestion = PlayerSubmission(playerID: author, question: question, answer: answer)
                    self.phase = .roundStart
                }
            case "questionSubmission":
                if let question = message["question"],
                   let answer = message["answer"],
                   let author = message["author"] {
                    let submission = PlayerSubmission(playerID: author, question: question, answer: answer)
                    self.questionSubmissions.append(submission)

                    if self.questionSubmissions.count >= self.expectedPlayers {
                        self.currentQuestion = self.questionSubmissions.randomElement()
//                        let hostID = self.discoveredPeers.first(where: { $0.value.isHost == "Y" })?.key.displayName
//                        let nonHostSubmissions = self.questionSubmissions.filter { $0.playerID != hostID }
                        //self.currentQuestion = nonHostSubmissions.randomElement()
                        self.phase = .roundStart
                        self.broadcastRoundStart(self.currentQuestion!)
                    } else {
                        if author != self.myPeerID.displayName &&
                           !self.questionSubmissions.contains(where: { $0.playerID == self.myPeerID.displayName }) {
                            self.phase = .questionSelect
                        } else {
                            self.phase = .waitingForQuestions
                        }
                    }
                }
            case "roundAnswer":
                if let answer = message["answer"],
                   let author = message["author"] {
                    let submission = PlayerSubmission(playerID: author, question: "", answer: answer)
                    self.roundAnswers.append(submission)
                    print(self.roundAnswers)
                    if self.roundAnswers.count >= self.expectedPlayers {
                        self.phase = .guessPhase
                        self.broadcastGuessStart()
                    } else {
                        if author != self.myPeerID.displayName &&
                            !self.roundAnswers.contains(where: { $0.playerID == self.myPeerID.displayName }) {
                            self.phase = .roundStart
                        } else {
                            self.phase = .waitingForAnswers
                        }
                    }
                }
            case "guessStart":
                self.phase = .guessPhase
            case "roundGuess":
                if let guess = message["answer"],
                   let author = message["author"] {
                    let submission = PlayerSubmission(playerID: author, question: "", answer: guess)
                    self.roundGuesses.append(submission)
                    if self.roundGuesses.count >= self.expectedPlayers {
                        self.phase = .results
                        self.broadcastResultsStart()
                    } else {
                        if author != self.myPeerID.displayName &&
                            !self.roundGuesses.contains(where: { $0.playerID == self.myPeerID.displayName }) {
                            self.phase = .guessPhase
                        } else {
                            self.phase = .waitingForGuesses
                        }
                    }
                }
            case "resultsStart":
                self.phase = .results
            default:
                break
            }

        }
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}

struct PlayerSubmission {
    let playerID: String
    let question: String
    let answer: String
}

enum GamePhase {
    case notStarted
    case questionSelect
    case waitingForQuestions
    case roundStart
    case waitingForAnswers
    case guessPhase
    case waitingForGuesses
    case results
}

struct TMUserInfo: Identifiable {
    let id = UUID()
    let isHost: Bool
    let username: String
    let profilePhoto: String
}
