import MultipeerConnectivity

class MCManager: NSObject, ObservableObject {
    static let shared = MCManager()
    private let serviceType = "takegames"

    private var peerID: MCPeerID
    private var session: MCSession
    private var advertiser: MCNearbyServiceAdvertiser?
    private var browser: MCNearbyServiceBrowser?

    @Published var roomCode: String = ""
    @Published var availableRooms: [String: MCPeerID] = [:] // Store rooms by code
    @Published var connectedPeers: [MCPeerID] = []
    @Published var foundPeer: MCPeerID?
    @Published var isReadyToNavigate: Bool = false

    override init() {
        let storedID = UserDefaults.standard.string(forKey: "mcPeerID") ?? UUID().uuidString
        UserDefaults.standard.set(storedID, forKey: "mcPeerID")

        let displayName = "\(UIDevice.current.name)-\(storedID.prefix(4))"
        peerID = MCPeerID(displayName: displayName)

        session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        super.init()

        session.delegate = self
    }

    // MARK: - Generate a Random 4-Letter Room Code
    private func generateRoomCode() -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        return String((0..<4).map { _ in letters.randomElement()! })
    }

    // MARK: - Hosting (Create Room)
    func startHosting() {
        roomCode = generateRoomCode() // Generate room code
        print("Hosting room with code: \(roomCode)")

        advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: ["roomCode": roomCode], serviceType: serviceType)
        advertiser?.delegate = self
        advertiser?.startAdvertisingPeer()
        
        isReadyToNavigate = true // Allow navigation
    }

    func stopHosting() {
        advertiser?.stopAdvertisingPeer()
        advertiser = nil
    }

    // MARK: - Joining (Search for Room)
    func startBrowsing(forRoomCode code: String) {
        browser = MCNearbyServiceBrowser(peer: peerID, serviceType: serviceType)
        browser?.delegate = self
        browser?.startBrowsingForPeers()
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.browser?.stopBrowsingForPeers()
        }
    }

    func stopBrowsing() {
        browser?.stopBrowsingForPeers()
        browser = nil
    }

    // MARK: - Sending Data
    func sendMessage(_ message: String) {
        guard !session.connectedPeers.isEmpty else { return }
        do {
            let data = message.data(using: .utf8)!
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Error sending message: \(error.localizedDescription)")
        }
    }
    
    func refreshConnectedPeers() {
        DispatchQueue.main.async {
            self.connectedPeers = self.session.connectedPeers + [self.peerID]
        }
    }
}

// MARK: - MCSessionDelegate
extension MCManager: MCSessionDelegate {
    // Called when a peer changes connection state (Connected, Connecting, Not Connected)
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            self.connectedPeers = session.connectedPeers + [self.peerID]
        }
        print("Peer \(peerID.displayName) changed state: \(state)")
        if state == .connected {
            print("\(peerID.displayName) has joined!")
            self.sendMessage("PlayerJoined:\(peerID.displayName)") // Notify others
        } else if state == .notConnected {
            print("\(peerID.displayName) has left!")
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let message = String(data: data, encoding: .utf8) {
            print("Received data: \(message) from \(peerID.displayName)")

            if message == "RequestRoomCode" {
                if let roomCodeData = self.roomCode.data(using: .utf8) {
                    try? session.send(roomCodeData, toPeers: [peerID], with: .reliable)
                    print("Sent room code to \(peerID.displayName)")
                } else {
                    print("nothing sent")
                }
            } else {
                DispatchQueue.main.async {
                    self.roomCode = message // Update room code if received from host
                }
            }
        }
    }

    // Required: Called when receiving a stream from a peer (Not used in most cases)
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        print("Received stream \(streamName) from \(peerID.displayName), but streaming is not implemented.")
    }

    // Required: Called when receiving a resource file from a peer (Not used in most cases)
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        print("Started receiving resource: \(resourceName) from \(peerID.displayName)")
    }

    // Required: Called when a resource file is fully received (Not used in most cases)
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        if let error = error {
            print("Error receiving resource \(resourceName): \(error.localizedDescription)")
        } else {
            print("Finished receiving resource \(resourceName) from \(peerID.displayName)")
        }
    }
}

// MARK: - MCNearbyServiceAdvertiserDelegate
extension MCManager: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, session)
    }
}

// MARK: - MCNearbyServiceBrowserDelegate
extension MCManager: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        if let roomCode = info?["roomCode"] {
            DispatchQueue.main.async {
                self.availableRooms[roomCode] = peerID
                self.foundPeer = peerID
                self.isReadyToNavigate = true // Allow navigation once peer is found
            }
            browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 10)
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        DispatchQueue.main.async {
            self.availableRooms = self.availableRooms.filter { $0.value != peerID }
        }
    }
}
