import SwiftUI

struct SwiftUIView: View {
    var body: some View {
        VStack(spacing: 10) {
            // Header
            HStack(spacing: 50) {
                Text("Settings and Activity")
            }
            
            Spacer()
                .frame(height: 20)
            
            // Settings Section
            VStack {
                // Account Privacy Row
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
                
                // Notifications Row
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
            
            // Log Out Button
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
