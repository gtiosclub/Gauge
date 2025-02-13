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
        "Game 1",
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
                Color(.systemGray5)  // Light gray
                    .edgesIgnoringSafeArea(.all)  // Fill the entire screen
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(games, id: \.self) { game in
                            Button(action: {
                                selectedGame = game
                                withAnimation {
                                    self.showingPopover.toggle()
                                }
                            }) {
                                VStack {
                                    Image("game_image")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(
                                            width: 300, height: 100,
                                            alignment: .center
                                        )
                                        .foregroundColor(.primary)

                                    Text(game)
                                        .font(.headline)
                                        .bold()
                                        .padding(.top, 8)
                                    Spacer()
                                }
                                .foregroundColor(.primary)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(5)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(5)
                        }
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
                        Text("Options for \(selectedGame ?? "Game")")
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
                    .padding()
                    Spacer()
                }
                .zIndex(1)  // Ensure the popover is on top
            }

        }
    }
}

#Preview {
    GamesHome()
}
