//
//  GamesHome.swift
//  Gauge
//
//  Created by Akshat Shenoi on 2/6/25.
//

import SwiftUI

struct GamesHome: View {
    // Will include a tab list view of all the games in the app
    let games: [String] = [
        "Take Match",
        "Game 2",
        "Game 3",
        "Game 4",
        "Game 5",
    ]
    @State private var selectedGame: String? = nil
    @State private var showingPopover = false
    @State private var showingJoin = false
    @State private var joinCode = ""

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(spacing: 10) {
                        Button(action: {
                            selectedGame = "Take Match"
                            withAnimation {
                                self.showingPopover.toggle()
                            }
                        }) {
                            GameCardView(gameTitle: "Take Match", playerRange: "3-8", duration: "15m", description: "Match your friends to their takes!")
                        }
//                        ForEach(games, id: \.self) { game in
//                            Button(action: {
//                                selectedGame = game
//                                withAnimation {
//                                    self.showingPopover.toggle()
//                                }
//                            }) {
//                                VStack {
//                                    Image("game_image")
//                                        .resizable()
//                                        .aspectRatio(contentMode: .fit)
//                                        .frame(
//                                            width: 300, height: 100,
//                                            alignment: .center
//                                        )
//                                        .foregroundColor(.primary)
//
//                                    Text(game)
//                                        .font(.headline)
//                                        .bold()
//                                        .padding(.top, 8)
//                                    Spacer()
//                                }
//                                .foregroundColor(.primary)
//                                .padding()
//                                .background(Color.white)
//                                .cornerRadius(5)
//                            }
//                            .buttonStyle(PlainButtonStyle())
//                            .padding(5)
//                        }
                    }
                    .padding()
                }
                .navigationTitle(Text("Games"))
            }

            if showingPopover {
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
                            .font(.title2)
                            .padding()
                        HStack {
                            Button(action: {
                            }) {
                                NavigationLink(destination: TakeMatchHome())
                                {
                                    Text("Create")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.blue)
                                        .cornerRadius(5)
                                }
                            }

                            Button(action: {
                                withAnimation {
                                    self.showingJoin = true
                                }
                            }) {
                                Text("Join")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.green)
                                    .cornerRadius(5)
                            }
                        }
                        if showingJoin {
                            HStack {
                                TextField("Enter room code", text: $joinCode)
                                    .textFieldStyle(
                                        RoundedBorderTextFieldStyle()
                                    )
                                    .padding()
                                Button(action: {
                                }) {
                                    NavigationLink(
                                        destination: TakeMatchHome()
                                    ) {
                                        Image(systemName: "chevron.right")
                                    }
                                }
                            }

                        }

                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(20)
                    .shadow(radius: 10)
                }
                .zIndex(1)  // Ensure the popover is on top
            }

        }
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
                .frame(height: 100) // Placeholder for image

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
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .shadow(radius: 5)
    }
}


#Preview {
    GamesHome()
}
