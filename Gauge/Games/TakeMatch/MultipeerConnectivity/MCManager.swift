import MultipeerConnectivity

extension String {
    
    static var serviceName = "takematch"
}

struct AdvertisedInfo {
    let roomCode: String?
    let username: String
    let profileLink: String
}

class MCManager: NSObject, ObservableObject {
    
    let serviceType = String.serviceName
    var session: MCSession
    var myPeerID: MCPeerID
    var nearbyServiceAdvertiser: MCNearbyServiceAdvertiser
    let nearbyServiceBrowser: MCNearbyServiceBrowser

    @Published var username: String
    @Published var profileLink: String
    @Published var connectedPeers: [MCPeerID] = []
    @Published var discoveredPeers: [MCPeerID: AdvertisedInfo] = [:]
    @Published var receivedInvite: Bool = false
    @Published var receievedInviteFrom: MCPeerID?
    @Published var invitationHandler: ((Bool, MCSession?) -> Void)?
    @Published var paired: Bool = false
    @Published var takeMatchAnswers: [Answer] = []
    @Published var gameStarted: Bool = false
    @Published var votes: [String: Int] = [:]

    var openRoomsCount: Int {
        let uniqueRoomCodes = Set(discoveredPeers.values.compactMap { $0.roomCode })
        return uniqueRoomCodes.count
    }

    func voteForQuestion(_ question: String) {
            let vote = Vote(question: question, sender: username)
            if let currentVoteCount = self.votes[vote.question] {
                self.votes[vote.question] = currentVoteCount + 1
            } else {
                self.votes[vote.question] = 1
            }
            do {
                let data = try JSONEncoder().encode(vote)
                try session.send(data, toPeers: session.connectedPeers, with: .reliable)
            } catch {
                print("Error sending vote: \(error)")
            }
        }

    func handleReceivedVote(_ vote: Vote) {
        DispatchQueue.main.async {
            if let currentVoteCount = self.votes[vote.question] {
                self.votes[vote.question] = currentVoteCount + 1
            } else {
                self.votes[vote.question] = 1
            }
        }
    }

    func tabulateVotes() {
        // Find the most-voted question
        let mostVotedQuestion = votes.max { a, b in a.value < b.value }?.key
        print(votes)
        if let question = mostVotedQuestion {
            TakeMatchSettingsVM.shared.question = question
            broadcastSelectedQuestion(question)
        }
    }

    func broadcastSelectedQuestion(_ question: String) {
        do {
            // Prepare the data to send the selected question
            let data = try JSONEncoder().encode(["selectedQuestion": question])

            // Send the data to all connected peers
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
            print("Broadcasting selected question: \(question)")
        } catch {
            print("Error sending selected question: \(error)")
        }
    }

    var isAvailableToPlay: Bool = false {
        didSet {
            
            if isAvailableToPlay {
                startAdvertising()
            } else {
                stopAdvertising()
            }
        }
    }
    
    init(yourName: String) {
        
        self.username = yourName
        self.profileLink = "TestProfile"
        myPeerID = MCPeerID(displayName: yourName)
        session = MCSession(peer: myPeerID)
        nearbyServiceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: serviceType)
        nearbyServiceBrowser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: serviceType)
        
        super.init()
        session.delegate = self
        nearbyServiceAdvertiser.delegate = self
        nearbyServiceBrowser.delegate = self
    }
    
    deinit {
        stopBrowsing()
        stopAdvertising()
    }
    
    func startAdvertising() {
        
        nearbyServiceAdvertiser.startAdvertisingPeer()
    }
    
    func stopAdvertising() {
        
        nearbyServiceAdvertiser.stopAdvertisingPeer()
    }
    
    func startBrowsing() {
        
        nearbyServiceBrowser.startBrowsingForPeers()

//     // MARK: - Joining (Search for Room)
//     func startBrowsing(forRoomCode code: String) {
//         browser = MCNearbyServiceBrowser(peer: peerID, serviceType: serviceType)
//         browser?.delegate = self
//         browser?.startBrowsingForPeers()
//         DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//             self.browser?.stopBrowsingForPeers()
//         }
    }
    
    func stopBrowsing() {
        nearbyServiceBrowser.stopBrowsingForPeers()
        discoveredPeers.removeAll()
    }
    
//    func restartHost() {
//        
//        connectedPeers = []
//        discoveredPeers = [:]
//        receivedInvite = false
//        paired = false
//        takeMatchAnswers = []
//        gameStarted = false
//        
//        stopBrowsing()
//        stopAdvertising()
//    }
    
    func setUsernameAndProfile(username: String, profileLink: String? = nil) {
        self.username = username
        nearbyServiceAdvertiser.stopAdvertisingPeer()
        let discoveryInfo: [String: String] = {
            var info = ["username": username]
            if let profileLink = profileLink {
                info["profileLink"] = profileLink
            }
            return info
        }()
        nearbyServiceAdvertiser = MCNearbyServiceAdvertiser(
            peer: myPeerID,
            discoveryInfo: discoveryInfo,
            serviceType: serviceType
        )
        nearbyServiceAdvertiser.delegate = self
        startAdvertising()
    }
    
    func startHosting(with roomCode: String) {
        stopAdvertising()
        nearbyServiceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: ["roomCode": roomCode, "username": username, "profileLink": profileLink], serviceType: serviceType)
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
    
    func submitAnswer(_ answerText: String) {
        let answer = Answer(sender: username, text: answerText)
        self.takeMatchAnswers.append(answer)
        // Then send the data asynchronously if needed
        if !session.connectedPeers.isEmpty {
            do {
                let data = try JSONEncoder().encode(answer)
                try session.send(data, toPeers: session.connectedPeers, with: .reliable)
            } catch {
                print("Error sending answer: \(error)")
            }
        }
    }
    
    func broadcastStartGame() {
        let message = "startGame"
        if let data = message.data(using: .utf8) {
            do {
                try session.send(data, toPeers: session.connectedPeers, with: .reliable)
            } catch {
                print("Error sending start game message: \(error)")
            }
        }
    }

    func broadcastQuestions(_ questions: [String]) {
        do {
            let data = try JSONEncoder().encode(["questions": questions])
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Error sending questions: \(error)")
        }
    }



    func broadcastGoToResults() {
        
        let message="goToResults"
        if let data = message.data(using: .utf8) {
            do {
                try session.send(data, toPeers: session.connectedPeers, with: .reliable)
            } catch {
                print("Error sending go to results message: \(error)")
            }
        }
    }

    func deleteRoom() {
        stopAdvertising()
        stopBrowsing()
        paired = false
        gameStarted = false
        votes.removeAll()
        takeMatchAnswers.removeAll()
        receivedInvite = false
        receievedInviteFrom = nil
        invitationHandler = nil
        discoveredPeers.removeAll()
        print("Room deleted.")
    }

    func disconnectFromSession() {
        username = ""
        session.disconnect() // Disconnect all peers
        session.delegate = nil // Remove delegate to prevent callbacks
        session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .none) // Reset session
        stopAdvertising()
        stopBrowsing()
        connectedPeers.removeAll()
        print("Disconnected from session.")
    }
}

extension MCManager: MCNearbyServiceBrowserDelegate {
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        
        DispatchQueue.main.async {
            
            let roomCode = info?["roomCode"] // might be nil for joiners
            let username = info?["username"] ?? peerID.displayName
            let profileLink = info?["profileLink"] ?? "TestProfile"
            let advertisedInfo = AdvertisedInfo(roomCode: roomCode, username: username, profileLink: profileLink)
            self.discoveredPeers[peerID] = advertisedInfo
            print("Open rooms: \(self.openRoomsCount)")
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
                
        DispatchQueue.main.async {
            self.discoveredPeers.removeValue(forKey: peerID)
            //self.connectedPeers = self.session.connectedPeers + [self.peerID]
        }
    }
}

extension MCManager: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        
        DispatchQueue.main.async {
            self.receivedInvite = true
            self.receievedInviteFrom = peerID
            self.invitationHandler = invitationHandler
            
            invitationHandler(true, self.session)
//             self.connectedPeers = session.connectedPeers + [self.peerID]
//         }
//         print("Peer \(peerID.displayName) changed state: \(state)")
//         if state == .connected {
//             print("\(peerID.displayName) has joined!")
//             self.sendMessage("PlayerJoined:\(peerID.displayName)") // Notify others
//         } else if state == .notConnected {
//             print("\(peerID.displayName) has left!")
        }
    }
}

extension MCManager: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        
        DispatchQueue.main.async {
            
            
            self.connectedPeers = session.connectedPeers
            
            switch state {
            case .notConnected:
                DispatchQueue.main.async {
                    if let index = self.connectedPeers.firstIndex(of: peerID) {
                        self.connectedPeers.remove(at: index)
                    }
                    self.paired = false
                    self.isAvailableToPlay = true
                    if self.connectedPeers.isEmpty {
                        print("All peers disconnected. Stopping room.")
                        self.deleteRoom()
                    }
                }
            case .connected:
                DispatchQueue.main.async {
                    self.paired = true
                    self.isAvailableToPlay = true
                }
            default:
                self.paired = false
                self.isAvailableToPlay = true
            }
        }
    }


    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let message = String(data: data, encoding: .utf8) {
            if message == "startGame" {
                DispatchQueue.main.async {
                    self.gameStarted = true
                }

            } else {
                if let decodedVote = try? JSONDecoder().decode(Vote.self, from: data) {
                    self.handleReceivedVote(decodedVote)
                } else if let decodedAnswer = try? JSONDecoder().decode(Answer.self, from: data) {
                    DispatchQueue.main.async {
                        self.takeMatchAnswers.append(decodedAnswer)
                    }
                } else {
                    do {
                        let decodedData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]

                        if let decodedData = decodedData {
                            if let receivedQuestions = decodedData["questions"] as? [String] {
                                TakeMatchSettingsVM.shared.questionOptions = receivedQuestions
                            }
                            else if let selectedQuestion = decodedData["selectedQuestion"] as? String {
                                DispatchQueue.main.async {
                                    TakeMatchSettingsVM.shared.question = selectedQuestion
                                }
                            }
                        }
                    } catch {
                        print("Error decoding data: \(error)")
                    }
                }
            }
        }
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: (any Error)?) {
        
    }
}



//// MARK: - MCNearbyServiceBrowserDelegate
//extension MCManager: MCNearbyServiceBrowserDelegate {
//    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
//        if let roomCode = info?["roomCode"] {
//            DispatchQueue.main.async {
//                self.availableRooms[roomCode] = peerID
//                self.foundPeer = peerID
//                self.isReadyToNavigate = true // Allow navigation once peer is found
//            }
//            browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 10)
//        }
//    }
//    
//    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
//        DispatchQueue.main.async {
//            self.availableRooms = self.availableRooms.filter { $0.value != peerID }
//        }
//    }
//}
