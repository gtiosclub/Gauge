import MultipeerConnectivity

extension String {
    
    static var serviceName = "takematch"
}

class MCManager: NSObject, ObservableObject {
    
    let serviceType = String.serviceName
    let session: MCSession
    let myPeerID: MCPeerID
    var nearbyServiceAdvertiser: MCNearbyServiceAdvertiser
    let nearbyServiceBrowser: MCNearbyServiceBrowser
    
    @Published var connectedPeers: [MCPeerID] = []
    @Published var discoveredPeers: [MCPeerID: String] = [:]
    @Published var receivedInvite: Bool = false
    @Published var receievedInviteFrom: MCPeerID?
    @Published var invitationHandler: ((Bool, MCSession?) -> Void)?
    @Published var paired: Bool = false
    
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
    }
    
    func stopBrowsing() {
        
        nearbyServiceBrowser.stopBrowsingForPeers()
        discoveredPeers.removeAll()
    }
    
    func startHosting(with roomCode: String) {
        stopAdvertising()
        nearbyServiceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: ["roomCode": roomCode], serviceType: serviceType)
        nearbyServiceAdvertiser.delegate = self
        startAdvertising()
    }
    
    func joinRoom(with code: String) {
        
        if let targetPeer = discoveredPeers.first(where: { $0.value == code })?.key {
            nearbyServiceBrowser.invitePeer(targetPeer, to: session, withContext: nil, timeout: 10)
        } else {
            print("No host found with room code: \(code)")
        }
    }
}

extension MCManager: MCNearbyServiceBrowserDelegate {
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        
        DispatchQueue.main.async {
            
            if let room = info?["roomCode"] {
                self.discoveredPeers[peerID] = room
            }
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
                
        DispatchQueue.main.async {
            self.discoveredPeers.removeValue(forKey: peerID)
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
                    self.paired = false
                    self.isAvailableToPlay = true
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
        
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: (any Error)?) {
        
    }
}


