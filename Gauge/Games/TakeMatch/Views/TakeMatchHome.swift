import SwiftUI

struct TakeMatchHome: View {
    @StateObject var mcManager = MCManager(yourName: UIDevice.current.identifierForVendor?.uuidString ?? UIDevice.current.name)
    @State var roomCode: String = ""
    @State var showJoinRoom: Bool = false
    @State var navigateToRoom = false
    @State var isHost = false

    var body: some View {
        NavigationStack {
            VStack {
                Text("Take Match")
                    .font(.largeTitle)
                    .bold()

                HStack {
                    // Create Room
                    Button(action: {
                        isHost = true
                        roomCode = generateRoomCode()
                        navigateToRoom = true
                        mcManager.startHosting(with: roomCode)
                    }) {
                        Text("Create Room")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(5)
                    }

                    // Join Room Button
                    Button(action: {
                        showJoinRoom.toggle()
                        isHost = false
                        mcManager.startBrowsing()
                    }) {
                        Text("Join Room")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(5)
                    }
                }

                if showJoinRoom {
                    HStack {
                        TextField("Enter Room Code", text: $roomCode)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                        
                        let roomAvailable = !roomCode.isEmpty && mcManager.discoveredPeers.values.contains(roomCode)

                        Button(action: {
                            if roomAvailable {
                                navigateToRoom = true
                                isHost = false
                                mcManager.joinRoom(with: roomCode)
                            }
                        }) {
                            Image(systemName: "arrow.right")
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(roomAvailable ? Color.blue : Color.gray)
                        .cornerRadius(5)
                        .disabled(!roomAvailable)
                    }
                }
            }
            .navigationDestination(isPresented: $navigateToRoom) {
                TakeMatchRoomView(mcManager: mcManager, isHost: isHost, roomCode: roomCode)
            }
        }
    }
    
    func generateRoomCode() -> String {
        
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        return String((0..<4).compactMap { _ in letters.randomElement() })
    }
}

#Preview {
    NavigationStack {
        TakeMatchHome()
    }
}
