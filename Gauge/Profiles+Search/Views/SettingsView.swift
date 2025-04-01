import SwiftUI

struct SwiftUIView: View {
    var body: some View {
        VStack(spacing: 10) {
            // Header
            GeometryReader { geometry in
                HStack {
                    NavigationLink(destination: Text("previous page")) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.blue)
                            .padding(.horizontal, 10)
                    }
                    .frame(width: geometry.size.width * 0.2, alignment: .leading)

                    Text("Settings and Activity")
                        .frame(width: geometry.size.width * 0.55, alignment: .center)

                    // Empty space on the right to balance the chevron
                    Spacer()
                        .frame(width: geometry.size.width * 0.2)
                }
            }
            .frame(height: 20) // header height
            
            Spacer()
                .frame(height: 20)
            
            // Settings Section
            VStack {
                HStack {
                    Image(systemName: "lock")
                        .foregroundColor(.black)
                    Text("Account Privacy")
                    Spacer()
                    NavigationLink(destination: Text("Account Privacy Screen")) {
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 5)

                Divider()
                    .padding(.horizontal, 20)

                HStack {
                    Image(systemName: "bell")
                        .foregroundColor(.black)
                    Text("Notifications")
                    Spacer()
                    NavigationLink(destination: Text("Notifications Screen")) {
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 5)

                Divider()
                    .padding(.horizontal, 20)
            }

            Spacer()

            NavigationLink(destination: Text("Log out")) {
                HStack {
                    Text("Log out")
                        .foregroundColor(.red)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 120)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                }
            }
        }
        .padding(.horizontal, 10)
    }
}

#Preview {
    SwiftUIView()
}
