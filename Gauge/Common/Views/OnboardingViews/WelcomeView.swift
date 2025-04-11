import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var authVM: AuthenticationVM
    @State private var showSignIn = false
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Text("Welcome to Gauge")
                .font(.largeTitle)
                .bold()
            
            Text("Share your takes. Connect with friends.")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Spacer()
            
            Button(action: {
                authVM.onboardingState = .email
            }) {
                Text("Get started!")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            
            Button(action: {
                showSignIn = true
            }) {
                Text("Already have an account? Sign in")
                    .foregroundColor(.blue)
            }
            .padding(.bottom)
        }
        .padding()
        .sheet(isPresented: $showSignIn) {
            SignInView()
                .environmentObject(authVM)
        }
    }
}
