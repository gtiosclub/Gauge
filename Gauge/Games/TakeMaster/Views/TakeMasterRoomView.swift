//
//  TakeMasterRoomView.swift
//  Gauge
//
//  Created by Akshat Shenoi on 4/6/25.
//

import SwiftUI
import MultipeerConnectivity

struct TakeMasterRoomView: View {
    @StateObject var tmManager: TMManager
    @EnvironmentObject private var userVm: UserFirebase
    @ObservedObject var gameSettings = TakeMatchSettingsVM.shared

    @State var showSettings: Bool = false
    @State private var navigateToTakeMatch = false
    @State private var fetchedPeers: Set<MCPeerID> = []

    @State private var userInfoMap: [MCPeerID: (username: String, profilePhoto: String)] = [:]

    var roomCode: String
    var onExit: () -> Void
    @State var isHost = false

    @Environment(\.dismiss) private var dismiss

    @State var answerText: String = ""

    func fetchUserInfo(for peer: MCPeerID, userID: String) {
        print("Fetching info for userID: \(userID)")
        userVm.getUsernameAndPhoto(userId: userID) { info in
            DispatchQueue.main.async {
                userInfoMap[peer] = (
                    info["username"] ?? "",
                    info["profilePhoto"] ?? ""
                )
                print("Received info for \(userID):", info)
            }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 10) {
                Text(tmManager.roomCode)
                    .font(.system(size: 64, weight: .medium)) // Closest to weight 510
                    .kerning(-0.704) // -1.1% of 64 = -0.704
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .lineSpacing(0) // Line height = 100%, so no extra spacing

                if isHost {
                    Button(action: {
                        tmManager.broadcastStartGame()
                        tmManager.gameStarted = true
                        tmManager.phase = .questionSelect
                    }) {
                        Text("START")
                            .font(.system(size: 30, weight: .medium)) // Closest to weight 510
                            .kerning(-0.704) // -1.1% of 64 = -0.704
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 150, maxHeight: 50, alignment: .center)
                            .lineSpacing(0) // Line height = 100%, so no extra spacing

                            .foregroundColor(.white)
                            .background(.black)
                            .cornerRadius(10)
                            .scaleEffect(1.0)
                    }
                    .frame(maxWidth: .infinity)
                    .buttonStyle(PressEffectButtonStyle())
                } else {
                    Text("Waiting for host to start...")
                        .font(.system(size: 16, weight: .medium)) // Closest to weight 510
                        .kerning(-0.704) // -1.1% of 64 = -0.704
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .lineSpacing(0) // Line height = 100%, so no extra spacing
                        .foregroundColor(Color(red: 138/255, green: 138/255, blue: 138/255))
                        .padding(.bottom, 10)

                }

                HStack {
                    VStack(spacing: 5) {
                        TMUserRowView(
                            isHost: tmManager.isHost == "Y",
                            username: tmManager.username,
                            profilePhoto: userVm.user.profilePhoto
                        )
                        ForEach(tmManager.connectedPeers, id: \.self) { peer in
                            TMUserRowView(
                                isHost: tmManager.discoveredPeers[peer]?.isHost == "Y",
                                username: userInfoMap[peer]?.username ?? "Loading...",
                                profilePhoto: userInfoMap[peer]?.profilePhoto ?? ""
                            )
                            .onAppear {
                                if let userId = tmManager.discoveredPeers[peer]?.profileLink,
                                   !fetchedPeers.contains(peer) {
                                    fetchUserInfo(for: peer, userID: userId)
                                    fetchedPeers.insert(peer)
                                }
                            }
                        }
                        Spacer()
                    }
                    .padding(.top, 20)
                    .padding(10)
                }
                .frame(maxWidth: .infinity, alignment: .top)
                .frame(maxHeight: .infinity)
                .background(Color(red: 238/255, green: 238/255, blue: 238/255))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .navigationTitle(Text("Take Master"))
            .background(Color.white)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .onAppear {
                isHost = tmManager.isHost == "Y"
            }
            .toolbar {
                if isHost {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showSettings.toggle()
                        }) {
                            Image(systemName: "gearshape")
                                .foregroundColor(.black)
                        }
                    }
                }

                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                tmManager.disconnectFromSession()
                                tmManager.stopBrowsing()
                            }
                            tmManager.isAvailableToPlay = false
                            onExit()
                            dismiss()
                        }
                    }) {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.black)
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                GameSettingsView(gameSettings: gameSettings, showSettings: $showSettings)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
        }
        .navigationDestination(isPresented: $tmManager.gameStarted) {
            TakeMasterView(manager: tmManager)
        }
    }
}
#Preview {
    TakeMasterRoomView(tmManager: TMManager(yourName: "hostguy", isHost: "Y"), gameSettings: TakeMatchSettingsVM(), showSettings: false, roomCode: "WXYZ", onExit: {}, isHost: true, answerText: "")
        .environmentObject(UserFirebase())

}

struct TMUserRowView: View {
    let isHost: Bool
    let username: String
    let profilePhoto: String
    let profilePhotoSize: CGFloat = 40

    var body: some View {
        ZStack {

            HStack {
                if profilePhoto != "", let url = URL(string: profilePhoto) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .frame(width: profilePhotoSize, height: profilePhotoSize)
                                .clipShape(Circle())
                        case .failure, .empty:
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: profilePhotoSize, height: profilePhotoSize)
                                .foregroundColor(.gray)
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: profilePhotoSize, height: profilePhotoSize)
                        .foregroundColor(.gray)
                }
                Text(username)
                    .font(.title2)
                    .padding(.leading, 10)
                Spacer()
                if (isHost) {
                    Image(systemName: "crown.fill")
                        .font(.title)
                        .foregroundColor(Color(red: 248/255, green: 192/255, blue: 21/255))
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white)
            )
        }
    }

}

//game settings sheet
struct TMGameSettingsView: View {


    @ObservedObject var gameSettings = TakeMatchSettingsVM.shared
    @Binding var showSettings: Bool

    var body: some View {

        VStack() {

            Spacer()
            Text("Game Settings")
                .font(.title)
                .padding()

            Form {
                HStack() {
                    Text("# of Rounds").font(.headline)
                    Section {

                        Picker("", selection: $gameSettings.numRounds) {

                            ForEach(1...5, id: \.self) { round in
                                Text("\(round)").tag(round)
                            }
                        }

                    }
                    .listRowBackground(Color(.systemGray4))
                }


                Text("Looking good?")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .center)

                Button(action: {
                    // Handle done action
                    showSettings = false
                }) {
                    Text("DONE")
                        .font(.headline)
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray3))
                        .cornerRadius(8)
                        .foregroundColor(.black)
                }
                Spacer()

            }
            .scrollContentBackground(.hidden)
            .background(.white)
        }
        .background(.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

}
