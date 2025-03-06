import SwiftUI

struct TakeMatchHome: View {
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
                        
                    }) {
                        Text("Create Room")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(5)
                    }

                    // Join Room Button
                    Button(action: {
                        
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
                           
                        }) {
                            Image(systemName: "arrow.right")
                        }
                        .padding()
                        .background(Color.gray)
                        .cornerRadius(5)
                    }
                }
            }
        }
    }
}

