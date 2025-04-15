//
//  StatisticsView.swift
//  Gauge
//
//  Created by Anthony Le on 4/9/25.
//

import SwiftUI
struct StatisticsView: View {
    @EnvironmentObject var userVM: UserFirebase
    var visitedUser: User
    @State private var totalVotes: Int = 0
    @State private var totalComments: Int = 0
    @State private var totalTakes: Int = 0
    @State private var totalTakeTime: Int = 0
    let gridColumns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    var body: some View {
        VStack(spacing: 20) {
            Text("\(visitedUser.username)'s Statistics")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top)
            LazyVGrid(columns: gridColumns, spacing: 16) {
                statCard(title: "Total Votes", value: "\(totalVotes)", footer: "Votes", gradient: [.orange.opacity(0.2), .white])
                statCard(title: "Total Comments", value: "\(totalComments)", footer: "Comments", gradient: [.blue.opacity(0.2), .white])
                statCard(title: "Total Take Time", value: "\(totalTakeTime)", footer: "Take Time", gradient: [.purple.opacity(0.2), .white])
                statCard(title: "Total Takes", value: "\(totalTakes)", footer: "Takes", gradient: [.red.opacity(0.2), .white])
            }
            .padding(.horizontal)
        }
        .padding(.bottom, 20)
        .onAppear {
            loadStats()
        }
    }
    func loadStats() {
        Task {
            do {
                async let (responses, comments, _) = userVM.getUserPostInteractions(userId: visitedUser.userId, setCurrentUserData: false)
                async let posts = userVM.getUserPosts(userId: visitedUser.userId, setCurrentUserData: false)
                let (res, com, postIds) = try await (responses, comments, posts)
                totalVotes = res.count
                totalComments = com.count
                totalTakes = postIds.count
                totalTakeTime = visitedUser.myTakeTime.count
            } catch {
                print("❌ Error loading statistics: \(error.localizedDescription)")
            }
        }
    }
    func statCard(title: String, value: String, footer: String, gradient: [Color]) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .minimumScaleFactor(0.75)
            Text(value)
                .font(.largeTitle)
                .fontWeight(.bold)
            Text(footer)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(minHeight: 140)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing))
                .shadow(radius: 2)
        )
    }
}
