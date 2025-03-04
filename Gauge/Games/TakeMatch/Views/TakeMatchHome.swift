import SwiftUI

struct TakeMatchHome: View {
    @StateObject var mcManager = MCManager(yourName: UIDevice.current.identifierForVendor?.uuidString ?? UIDevice.current.name)
    @State var roomCode: String = ""
    @State var username: String = ""
    @State var showJoinRoom: Bool = false
    @State var navigateToRoom = false
    @State var isHost = false

    var body: some View {
        NavigationStack {
            VStack {
                Text("Take Match")
                    .font(.largeTitle)
                    .bold()
                
                TextField("Enter Username", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                HStack {
                    // Create Room
                    Button(action: {
                        mcManager.username = username
                        isHost = true
                        roomCode = generateRoomCode()
                        navigateToRoom = true
                        mcManager.startHosting(with: roomCode)
                        mcManager.startBrowsing()
                    }) {
                        Text("Create Room")
                            .padding()
                            .background(!username.isEmpty ? Color.blue : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(5)
                    }
                    .disabled(username.isEmpty)

                    // Join Room Button
                    Button(action: {
                        showJoinRoom.toggle()
                        mcManager.setUsername(username: username)
                        isHost = false
                        mcManager.startBrowsing()
                    }) {
                        Text("Join Room")
                            .padding()
                            .background(!username.isEmpty ? Color.blue : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(5)
                    }
                    .disabled(username.isEmpty)
                }

                if showJoinRoom {
                    HStack {
                        VStack {
                            TextField("Enter Room Code", text: $roomCode)
                                .textFieldStyle(RoundedBorderTextFieldStyle())

                        }
                                                
                        let roomAvailable = !roomCode.isEmpty && mcManager.discoveredPeers.values.contains { $0.roomCode == roomCode }


                        Button(action: {
                            if roomAvailable {
                                mcManager.username = username
                                navigateToRoom = true
                                isHost = false
                                mcManager.joinRoom(with: roomCode)
                                //mcManager.sendMessage("RequestRoomCode")
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
                TakeMatchRoomView(mcManager: mcManager, isHost: isHost, roomCode: roomCode, onExit: resetHomeState)
            }
            .navigationBarBackButtonHidden()
        }
    }
    
    func generateRoomCode() -> String {
        
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        return String((0..<4).compactMap { _ in letters.randomElement() })
    }
    
    func resetHomeState() {
        roomCode = ""
        showJoinRoom = false
        navigateToRoom = false
        isHost = false
    }
}

#Preview {
    NavigationStack {
        TakeMatchHome()
    }
}
