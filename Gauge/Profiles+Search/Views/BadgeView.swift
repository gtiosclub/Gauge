import SwiftUI

struct BadgesView: View {
    let badges: [BadgeModel] = [
        BadgeModel(id: 1, title: "Fire Voter", description: "Voted 100 times", imageName: "firevoter"),
        BadgeModel(id: 2, title: "Take Master", description: "Posted 50 takes", imageName: "takemaster"),
        BadgeModel(id: 3, title: "Casual Challenger", description: "Played 10 games", imageName: "game"),
        BadgeModel(id: 4, title: "Controversial Ratio", description: "Hits 60:40", imageName: "ratio"),
        BadgeModel(id: 5, title: "Locked", description: "", imageName: "unlocked")
    ]
    
    var onBadgeTap: (BadgeModel) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Total Badges: \(badges.count)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.leading)
                Spacer()
            }
            .padding(.top)

            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 28) {
                    ForEach(badges) { badge in
                        Button(action: {
                            onBadgeTap(badge)
                        }) {
                            BadgeView(badge: badge)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 10)
            }
        }
    }
}

struct BadgeModel: Identifiable {
    let id: Int
    let title: String
    let description: String
    let imageName: String
}

struct BadgeView: View {
    let badge: BadgeModel
    
    var body: some View {
        VStack(spacing: 8) {
            Image(badge.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 70, height: 70)
                .clipShape(Circle())
                .shadow(radius: 1)

            Text(badge.title)
                .font(.system(size: 14))
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .frame(height: 38)
                .foregroundColor(.black)
        }
    }
}

struct BadgeDetailView: View {
    let badge: BadgeModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.gray)
                        .font(.system(size: 20))
                        .padding()
                }
            }

            Image(badge.imageName)
                .resizable()
                .frame(width: 150, height: 150)
                .clipShape(Circle())
                .shadow(radius: 3)

            Text(badge.title)
                .font(.title)
                .fontWeight(.bold)
                .padding(.top)

            Text(badge.description)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()
        }
        .padding(.top, 20)
    }
}

struct BadgesView_Previews: PreviewProvider {
    static var previews: some View {
        BadgesView(onBadgeTap: { _ in })
    }
}

