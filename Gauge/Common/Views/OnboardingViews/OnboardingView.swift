import SwiftUI

struct OnboardingView: View {
    @StateObject private var authVM = AuthenticationVM()
    
    var body: some View {
        NavigationView {
            contentView
                .environmentObject(authVM)
                .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        switch authVM.onboardingState {
        case .welcome:
            WelcomeView()
        case .email:
            EmailView()
        case .username:
            UsernameView()
        case .password:
            PasswordView(
                email: authVM.tempUserData.email,
                username: authVM.tempUserData.username
            )
        case .gender:
            GenderSelectionView()
        case .location:
            LocationSelectionView()
        case .profileEmoji:
            EmojiSelectionView()
        case .bio:
            BioCreationView()
        case .categories:
            CategorySelectionView()
        case .attributes:
            AttributeFormView()
        case .complete:
            FeedView()
                .environmentObject(UserFirebase())
                .environmentObject(PostFirebase())
        }
    }
}
