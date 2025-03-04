import SwiftUI

struct MatchView: View {
    @Binding var iconBank: [String]
    @Binding var responseGuesses: [String?]
    @Binding var isTargeted: [Bool]
    var responses: [String] // Add this parameter
    var onSubmit: () -> Void

    // Adaptive column setup for wrapping behavior
    let columns = [
        GridItem(.adaptive(minimum: 150, maximum: 200), spacing: 30)
    ]

    var body: some View {
        VStack(spacing: 20) {
            // Icon Bank (Unassigned Icons)
            ResponseView(response: "", icons: iconBank, isTargeted: false)
                .dropDestination(for: String.self) { droppedIcons, _ in
                    for icon in droppedIcons {
                        if let responseIndex = responseGuesses.firstIndex(where: { $0 == icon }) {
                            responseGuesses[responseIndex] = nil
                        }
                        if !iconBank.contains(icon) { // Prevent duplicates
                            iconBank.append(icon)
                        }
                    }
                    return true
                }
            
            // Response Boxes Grid
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(Array(responses.enumerated()), id: \.offset) { index, response in
                    ResponseView(response: response, icons: responseGuesses[index] == nil ? [] : [responseGuesses[index]!], isTargeted: isTargeted[index])
                        .dropDestination(for: String.self) { droppedIcons, _ in
                            guard let newIcon = droppedIcons.first else { return false }
                            if let oldIndex = responseGuesses.firstIndex(where: { $0 == newIcon }) {
                                responseGuesses[oldIndex] = responseGuesses[index]
                            } else {
                                iconBank.removeAll { $0 == newIcon }
                            }
                            if let existingIcon = responseGuesses[index] {
                                if !iconBank.contains(existingIcon) && !responseGuesses.contains(existingIcon) {
                                    iconBank.append(existingIcon)
                                }
                            }
                            responseGuesses[index] = newIcon
                            return true
                        } isTargeted: { targeted in
                            isTargeted[index] = targeted
                        }
                }
            }
            .padding(.horizontal)
            Button(action: {
                onSubmit()
            }) {
                Text("Submit")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.gray)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.2), radius: 4, x: 2, y: 2)
                    .scaleEffect(1.0)
            }
            .buttonStyle(PressEffectButtonStyle())
            .padding(.horizontal, 40)
            .padding(.top, 20)
        }
        .padding()
    }
}

struct ResponseView: View {
    let response: String
    let icons: [String]
    let isTargeted: Bool

    var body: some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .frame(width: 160, height: 160)
                    .foregroundColor(isTargeted ? .teal.opacity(0.2) : Color(.secondarySystemFill))
                Text(response)
                    .font(.title)
                    .frame(maxWidth: 160)
                    ForEach(icons, id: \.self) { icon in
                        Text(icon)
                            .padding(12)
                            .background(Color.gray)
                            .cornerRadius(8)
                            .shadow(radius: 1, x: 1, y: 1)
                            .draggable(icon)
                }
            }
        }
        .frame(width: 160)
    }
}
