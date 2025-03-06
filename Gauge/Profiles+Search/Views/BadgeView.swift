import SwiftUI

struct BadgesView: View {
    let badges: [BadgeModel] = [
        BadgeModel(id: 1, title: "Fire Voter", description: "Voted on 500 takes"),
        BadgeModel(id: 2, title: "Posting Warrior", description: "Posted 50 takes"),
        BadgeModel(id: 3, title: "Rising Star", description: "Gained 25 followers"),
        BadgeModel(id: 4, title: "Top Rank", description: "Top 1% of Voters"),
    ]
    
    var onBadgeTap: (BadgeModel) -> Void

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Badges")
                    .font(.headline)
                    .padding(.leading)
                
                Spacer()
                
                Text("total badges: \(badges.count)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.trailing)
            }
            .padding(.top)
            
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 20) {
                    ForEach(badges) { badge in
                        Button(action: {
                            onBadgeTap(badge)
                        }) {
                            BadgeView(badge: badge)
                        }
                    }
                }
                .padding()
            }
        }
        .background(Color(UIColor.systemBackground))
    }
}

struct BadgeModel: Identifiable {
    let id: Int
    let title: String
    let description: String
}

struct BadgeView: View {
    let badge: BadgeModel
    
    var body: some View {
        VStack {
            Diamond()
                .frame(width: 80, height: 80)
                .foregroundColor(Color(UIColor.systemGray5))
                .shadow(radius: 1)
            
            Text(badge.title)
                .font(.system(size:16))
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .frame(height: 40)
                .foregroundColor(.black)
        }
        .padding(.bottom, 5)
    }
}

struct Diamond: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let midX = rect.midX
        let midY = rect.midY
        
        path.move(to: CGPoint(x: midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: midY))
        path.addLine(to: CGPoint(x: midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: midY))
        path.closeSubpath()
        
        return path
    }
}


struct BadgeDetailView: View {
    let badge: BadgeModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            // Close button (X) in top right corner
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
            
            // Badge image (larger, centered)
            Circle()
                .frame(width: 150, height: 150)
                .foregroundColor(Color(UIColor.systemGray5))
            
            // Badge title
            Text(badge.title)
                .font(.title)
                .fontWeight(.bold)
                .padding(.top)
            
            // Badge description
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
