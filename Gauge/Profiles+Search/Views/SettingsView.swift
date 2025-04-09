import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authVM: AuthenticationVM
    
    var body: some View {
        NavigationView {
            List {
                // Settings sections
                Section {
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
                    .padding(.vertical, 5)

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
                    .padding(.vertical, 5)
                }
                
                // Sign out section
                Section {
                    Button(action: {
                        authVM.signOut()
                        dismiss()
                    }) {
                        Text("Sign Out")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AuthenticationVM())
}
