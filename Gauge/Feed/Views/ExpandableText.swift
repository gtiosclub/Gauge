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

    var body: some View {
        withAnimation() {
            VStack(alignment: .leading) {
                Text(text)
                    .lineLimit(expanded ? nil : lineLimit)
                
                    .background(
                        Text(text).lineLimit(lineLimit)
                            .background(GeometryReader { displayedGeometry in
                                ZStack {
                                    Text(self.text)
                                        .background(GeometryReader { fullGeometry in
                                            Color.clear.onAppear {
                                                self.truncated = fullGeometry.size.height > displayedGeometry.size.height
                                            }
                                        })
                                }
                                .frame(height: .greatestFiniteMagnitude)
                            })
                            .hidden()
                    )
                
                if truncated { toggleButton }
            }
        }
    }

    var toggleButton: some View {
        Button(action: {
            withAnimation {
                self.expanded.toggle()
            }
        }) {
            Text(self.expanded ? "Show less" : "Show more")
                .font(.caption)
        }
    }
}

#Preview {
    ExpandableText("Love seeing all the amazing things happening here! Keep up the great work, everyone. 💯✨ #Inspiration #Community. Love seeing all the amazing things happening here! Keep up the great work, everyone. 💯✨ #Inspiration #Community.")
}
