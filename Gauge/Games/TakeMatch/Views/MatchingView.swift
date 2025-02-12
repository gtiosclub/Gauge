//
//  TakeMatchMatchingView.swift
//  Gauge
//
//  Created by Seohyun Park on 2/11/25.
//

import SwiftUI

struct MatchingView: View {
    var responses: [String]
    var playerPictures: [String]
    @State var circlePosition: CGPoint = .zero
    @Binding var guessedMatches: [String: String]
    var onSubmit: () -> Void
    var body: some View {
        VStack {
            Text("Match").font(.largeTitle.bold())
            ZStack() {
                Rectangle()
                    .foregroundColor(Color(.secondarySystemFill))
                ZStack {
                    VStack(spacing: 12) {
                        ForEach(responses, id: \.self) { response in
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white)
                                    .shadow(radius: 1.5, x: 1.5, y: 1.5)
                                Text(response)
                                    .font(.title)
                            }.dropDestination(for: Image.self) {
                                playerSelection, location in
                                circlePosition = location
                                return true
                            }
                        }
                        Spacer()
                    }
                    .padding(.vertical)
                }.padding(.horizontal)
            }
            Spacer()
            ForEach(playerPictures, id: \.self) { imageName in
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
                    .shadow(radius: 1.5, x: 1.5, y: 1.5)
                    .draggable(
                        Image(imageName))
            }
        }
    }
}

#Preview {
    MatchingView(responses: ["Pizza", "Hamburgers", "Fried Chicken", "Ice Cream"], playerPictures: ["TestProfile"], guessedMatches: .constant([:]), onSubmit: { })
}
