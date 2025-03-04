//
//  Untitled.swift
//  Gauge
//
//  Created by Seohyun Park on 2/27/25.
//

import SwiftUI
import Algorithms

struct Untitled: View {


    @State private var iconBank: [String] = ["Player 1", "Player 2", "Player 3", "Player 4"]
    @State private var response1guess: [String] = []
    @State private var response2guess: [String] = []
    @State private var response3guess: [String] = []
    @State private var response4guess: [String] = []


    var body: some View {
        HStack(spacing: 12) {
            KanbanView(response: "Icon Bank", icons: iconBank)
            KanbanView(response: "Response 1", icons: response1guess)
                .dropDestination(for: String.self) { droppedIcons, location in
                    for icon in droppedIcons {
                        iconBank.removeAll { $0 == icon }
                        response2guess.removeAll { $0 == icon }
                        response3guess.removeAll { $0 == icon }
                        response4guess.removeAll { $0 == icon }
                    }
                    let totalIcons = response1guess + droppedIcons
                    response1guess = Array(totalIcons.uniqued())
                    return true
                }
            KanbanView(response: "Response 2", icons: response2guess)
            KanbanView(response: "Response 3", icons: response3guess)
            KanbanView(response: "Response 4", icons: response4guess)

        }
        .padding()
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Untitled()
            .previewInterfaceOrientation(.landscapeRight)
    }
}


struct KanbanView: View {


    let response: String
    let icons: [String]


    var body: some View {
        VStack(alignment: .leading) {
            Text(response).font(.footnote.bold())

            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(Color(.secondarySystemFill))

                VStack(alignment: .leading, spacing: 12) {
                    ForEach(icons, id: \.self) { icon in
                        Text(icon)
                            .padding(12)
                            .background(Color(uiColor: .secondarySystemGroupedBackground))
                            .cornerRadius(8)
                            .shadow(radius: 1, x: 1, y: 1)
                            .draggable(icon)
                    }
                    Spacer()
                }
                .padding(.vertical)
            }
        }
    }
}
