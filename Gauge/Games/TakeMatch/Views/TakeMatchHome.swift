import SwiftUI

struct TakeMatchHome: View {
    @StateObject private var mcManager = MCManager.shared
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
                        mcManager.startHosting()
                        isHost = true
                        navigateToRoom = true
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

                        Button(action: {
                            mcManager.startBrowsing(forRoomCode: roomCode)
                            if mcManager.availableRooms[roomCode] != nil {
                                navigateToRoom = true
                                isHost = false
                                mcManager.sendMessage("RequestRoomCode")

                            }
                        }) {
                            Image(systemName: "arrow.right")
                        }
                        .padding()
                        .background(Color.gray)
                        .cornerRadius(5)
                    }
                }
            }
            .navigationDestination(isPresented: $navigateToRoom) {
                TakeMatchRoomView(isHost: isHost)
            }
        }
    }
}

#Preview {
    NavigationStack {
        TakeMatchHome()
    }
}
