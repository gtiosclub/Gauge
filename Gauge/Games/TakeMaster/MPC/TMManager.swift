import MultipeerConnectivity

class TMManager: NSObject, ObservableObject {

    private let serviceType = String.serviceName
    private var session: MCSession
    private var myPeerID: MCPeerID
    private var nearbyServiceAdvertiser: MCNearbyServiceAdvertiser
    private let nearbyServiceBrowser: MCNearbyServiceBrowser

    @Published var username: String
    @Published var profileLink: String
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

    var openRoomsCount: Int {
        return Set(discoveredPeers.values.compactMap { $0.roomCode }).count
    }

    init(yourName: String) {
        self.username = yourName
        self.profileLink = "TestProfile"
        self.myPeerID = MCPeerID(displayName: yourName)
        self.session = MCSession(peer: myPeerID)
        self.nearbyServiceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: serviceType)
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
    func setUsernameAndProfile(username: String, profileLink: String? = nil) {
        self.username = username
        nearbyServiceAdvertiser.stopAdvertisingPeer()
        let discoveryInfo: [String: String] = ["username": username, "profileLink": profileLink ?? "TestProfile"]
        nearbyServiceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: discoveryInfo, serviceType: serviceType)
        nearbyServiceAdvertiser.delegate = self
        startAdvertising()
    }

    // MARK: - Room Management
    func startHosting(with roomCode: String) {
        stopAdvertising()
        let discoveryInfo: [String: String] = ["roomCode": roomCode, "username": username, "profileLink": profileLink]
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
        let message = "startGame"
        if let data = message.data(using: .utf8) {
            do {
                try session.send(data, toPeers: session.connectedPeers, with: .reliable)
            } catch {
                print("Error sending start game message: \(error)")
            }
        }
    }

    func deleteRoom() {
        stopAdvertising()
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
        username = ""
        session.disconnect()
        session.delegate = nil
        session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .none)
        stopAdvertising()
        stopBrowsing()
        connectedPeers.removeAll()
        print("Disconnected from session.")
    }
}

extension TMManager: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        DispatchQueue.main.async {
            let roomCode = info?["roomCode"]
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
            case .notConnected:
                if let index = self.connectedPeers.firstIndex(of: peerID) {
                    self.connectedPeers.remove(at: index)
                }
                self.paired = false
                self.isAvailableToPlay = true
                if self.connectedPeers.isEmpty {
                    print("All peers disconnected. Stopping room.")
                    self.deleteRoom()
                }
            case .connected:
                self.paired = true
                self.isAvailableToPlay = true
            default:
                self.paired = false
                self.isAvailableToPlay = true
            }
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let message = String(data: data, encoding: .utf8), message == "startGame" {
            DispatchQueue.main.async {
                self.gameStarted = true
            }
        }
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}
