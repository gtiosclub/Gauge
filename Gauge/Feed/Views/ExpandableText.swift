//
//  LongText.swift
//  Gauge
//
//  Created by Krish Prasad on 2/27/25.
//

import SwiftUI

struct ExpandableText: View {

    /* Indicates whether the user want to see all the text or not. */
    @State private var expanded: Bool = false

    /* Indicates whether the text has been truncated in its display. */
    @State private var truncated: Bool = false

    private var text: String

    var lineLimit = 3

    init(_ text: String) {
        self.text = text
    }
    
    private func determineTruncation(_ geometry: GeometryProxy) {
        // Calculate the bounding box we'd need to render the
        // text given the width from the GeometryReader.
        let total = self.text.boundingRect(
            with: CGSize(
                width: geometry.size.width,
                height: .greatestFiniteMagnitude
            ),
            options: .usesLineFragmentOrigin,
            attributes: [.font: UIFont.systemFont(ofSize: 16)],
            context: nil
        )

        if total.size.height > geometry.size.height {
            self.truncated = true
        }
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text(text)
                .lineLimit(expanded ? nil : lineLimit)
                .background(GeometryReader { geometry in
                    Color.clear.onAppear {
                        self.determineTruncation(geometry)
                    }
                })

            if self.truncated {
                toggleButton
            }
        }
    }

    var toggleButton: some View {
        Button(action: {
            withAnimation() {
                self.expanded.toggle()
            }
        }) {
            Text(self.expanded ? "Show less" : "Show more")
                .font(.caption)
        }
    }
}

#Preview {
    ExpandableText("Love seeing all the amazing things happening here! Keep up the great work, everyone. 💯✨ #Inspiration #Co")
}
