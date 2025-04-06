//
//  GamesHome.swift
//  Gauge
//
//  Created by Akshat Shenoi on 2/6/25.
//

import SwiftUI

struct GamesHome: View {
    @EnvironmentObject var userVM: UserFirebase
    @State private var selectedGame: String? = nil
    @State private var showingPopover = false
    @State private var showingJoin = false
    @State var roomCode = ""
    @State var username: String = ""
    @State var profileLink: String = "TestProfile"
    @State var isHost = false
    @ObservedObject var mcManager = MCManager(yourName: UIDevice.current.identifierForVendor?.uuidString ?? UIDevice.current.name)
    @ObservedObject var tmManager = TMManager(yourName: UIDevice.current.identifierForVendor?.uuidString ?? UIDevice.current.name)
    @State var showJoinRoom: Bool = false
    @State var navigateToRoom = false

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(spacing: 10) {
                        Button(action: {
                            selectedGame = "Take Master"
                            withAnimation {
                                username = userVM.user.username
                                profileLink = userVM.user.userId
                                self.showingPopover.toggle()
                            }
                        }) {
                            GameCardView(
                                gameTitle: "Take Master", playerRange: "4",
                                duration: "5m",
                                description:
                                    "Make as many takes as you can!")
                        }
                        Button(action: {
                            selectedGame = "Take Match"
                            withAnimation {
                                username = userVM.user.username
                                self.showingPopover.toggle()
                            }
                        }) {
                            GameCardView(
                                gameTitle: "Take Match", playerRange: "3-8",
                                duration: "15m",
                                description:
                                    "Match your friends to their takes!")
                        }
                        Button(action: {
                            selectedGame = "Take Time"
                            withAnimation {
                                username = userVM.user.username
                                self.showingPopover.toggle()
                            }
                        }) {
                            GameCardView(
                                gameTitle: "Take Time", playerRange: "1",
                                duration: "5m",
                                description:
                                    "Speedrun takes!")
                        }
                    }
                    .padding()
                }


                if showingPopover {
                    ZStack {
                        Color.black.opacity(0.3)
                            .edgesIgnoringSafeArea(.all)
                            .onTapGesture {
                                withAnimation {
                                    self.showingPopover = false
                                    self.showingJoin = false
                                }
                            }

                        VStack {
                            VStack(spacing: 20) {
                                HStack {
                                    Button(action: {
                                        withAnimation {

                                            self.showingPopover = false
                                            self.showingJoin = false
                                        }
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.title2)
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                }
                                Text(selectedGame ?? "")
                                    .font(.title)
                                    .padding()
                                HStack {
                                    Button(action: {
                                        mcManager.setUsernameAndProfile(username: username, profileLink: profileLink)
                                        isHost = true
                                        roomCode = generateRoomCode()
                                        navigateToRoom = true
                                        mcManager.startHosting(with: roomCode)
                                        mcManager.startBrowsing()
                                    }) {
                                        Text("Create")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                            .padding()
                                            .frame(maxWidth: .infinity)
                                            .background(Color.blue)
                                            .cornerRadius(10)
                                    }
                                    .disabled(username.isEmpty)

                                    Button(action: {
                                        withAnimation {
                                            showingJoin.toggle()
                                            mcManager.setUsernameAndProfile(username: username, profileLink: profileLink)
                                            isHost = false
                                            mcManager.startBrowsing()
                                        }
                                    }) {
                                        Text("Join")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                            .padding()
                                            .frame(maxWidth: .infinity)
                                            .background(Color.green)
                                            .cornerRadius(10)
                                    }
                                    .disabled(username.isEmpty)
                                }
                                TextField(
                                    "Username", text: $username
                                )
                                .font(.title2)
                                .textFieldStyle(
                                    RoundedBorderTextFieldStyle()
                                )
                                if showingJoin {
                                    HStack {
                                        TextField("Room Code", text: $roomCode)
                                            .onChange(of: roomCode) { newValue in
                                                roomCode = newValue.uppercased()
                                            }
                                        .font(.title2)
                                        .textFieldStyle(
                                            RoundedBorderTextFieldStyle()
                                        )
                                        let roomAvailable = !roomCode.isEmpty && mcManager.discoveredPeers.values.contains { $0.roomCode == roomCode }
                                        Button(action: {
                                            if roomAvailable {
                                                mcManager.setUsernameAndProfile(username: username, profileLink: profileLink)
                                                isHost = false
                                                mcManager.joinRoom(with: roomCode)
                                                navigateToRoom = true
                                            }
                                        }) {
                                            Image(systemName: "arrow.right")
                                        }
                                        .disabled(username.isEmpty || roomCode.isEmpty || !roomAvailable)
                                        
                                    }

                                }

                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(20)
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle(Text("Games"))
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

struct GameCardView: View {
    var gameTitle: String
    var playerRange: String
    var duration: String
    var description: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.3))
                .frame(height: 100)  // Placeholder for image

            HStack(spacing: 10) {
                Text(gameTitle)
                    .font(.title)
                    .fontWeight(.bold)
                Label(playerRange, systemImage: "person.2.fill")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Label(duration, systemImage: "clock")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            Text(description)
                .font(.body)
                .foregroundColor(.black)
                .lineLimit(2)
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(radius: 5)

    }
}

#Preview {
    GamesHome()
        .environmentObject(UserFirebase())
}
