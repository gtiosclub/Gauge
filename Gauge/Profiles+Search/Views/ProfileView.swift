import SwiftUI
import Firebase

struct ProfileView: View {
    @EnvironmentObject var userVM: UserFirebase
    @EnvironmentObject var postVM: PostFirebase
    @EnvironmentObject var authVM: AuthenticationVM
    @StateObject var profileViewModel = ProfileViewModel()
    
    @State private var selectedTab: String = "Takes"
    @State private var selectedBadge: BadgeModel? = nil
    @State private var showingTakeTimeResults = false
    @State private var showingSettings = false
    let userTags = ["📏5'9", "📍Atlanta", "🔒Single", "🎓College"]
    @State private var profileImage: UIImage?
    let tabs = ["Takes", "Votes", "Comments", "Badges", "Statistics", "Favorites"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    HStack {
                        Spacer()
                        Menu {
                            NavigationLink(destination: ProfileEditView()) {
                                Label("Edit Profile", systemImage: "pencil")
                            }
                            Button(action: {
                                showingSettings = true
                            }) {
                                Label("Settings", systemImage: "gearshape")
                            }
                        } label: {
                            Image(systemName: "line.3.horizontal")
                                .resizable()
                                .frame(width: 20, height: 15)
                                .foregroundColor(.black)
                                .padding(6)
                        }
                    }
                    .padding(.top, 5)
                    
                    HStack {
                        ZStack {
                            if let emoji = userVM.user.attributes["profileEmoji"], !emoji.isEmpty {
                                Text(emoji)
                                    .font(.system(size: 60))
                            } else if let url = URL(string: userVM.user.profilePhoto),
                                      !userVM.user.profilePhoto.isEmpty {
                                AsyncImage(url: url) { phase in
                                    if let image = phase.image {
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 80, height: 80)
                                            .clipShape(Circle())
                                    } else if phase.error != nil {
                                        Circle()
                                            .fill(Color.gray)
                                            .frame(width: 80, height: 80)
                                    } else {
                                        ProgressView()
                                            .frame(width: 80, height: 80)
                                    }
                                }
                            } else {
                                Circle()
                                    .frame(width: 80, height: 80)
                                    .foregroundColor(.gray)
                            }
                            
                            Button(action: {
                                showingTakeTimeResults = true
                            }) {
                                Circle()
                                    .foregroundColor(Color.black.opacity(0))
                                    .frame(width: 80, height: 80)
                                    .overlay(
                                        Circle()
                                            .stroke(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [.blue, .purple]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 3
                                            )
                                            .opacity(userVM.user.myTakeTime.isEmpty ? 0 : 1)
                                    )
                            }
                            .disabled(userVM.user.myTakeTime.isEmpty)
                        }
                        .padding(.leading, 16)
                        
                        VStack(alignment: .leading) {
                            Text(userVM.user.username)
                                .font(.system(size: 30))
                                .fontWeight(.medium)
                            
                            NavigationLink(destination: FriendsView(viewModel: FriendsViewModel(user: userVM.user), currentUser: userVM.user)) {
                                HStack {
                                    Text("\(userVM.user.friends.count)")
                                        .foregroundColor(.black)
                                        .font(.system(size: 18))
                                    Text("Friends")
                                        .foregroundColor(Color(.systemGray))
                                        .font(.system(size: 18))
                                }
                            }
                        }
                        Spacer()
                    }
                    
                    // User Tags
                    HStack {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(userTags, id: \.self) { tag in
                                    Text(tag)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 6)
                                        .font(.system(size: 14))
                                        .background(Color.gray.opacity(0.2))
                                        .foregroundColor(.black)
                                        .cornerRadius(15)
                                }
                            }
                        }
                        .padding(.leading, 20)
                        .padding(.top, 10)
                    }
                    
                    HStack {
                        Text("A short bio that describes you")
                            .padding(.leading, 20)
                        Spacer()
                    }
                    .padding(.top, 10)
                    VStack(spacing: 0) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(tabs, id: \.self) { tab in
                                    TabButton(title: tab, selectedTab: $selectedTab)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.top, 5)
                        
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(Color(.systemGray))
                            .ignoresSafeArea(.container, edges: .horizontal)
                    }
                    
                    // Content based on the selected tab.
                    if selectedTab == "Badges" {
                        BadgesView(onBadgeTap: { badge in
                            selectedBadge = badge
                        })
                    } else if selectedTab == "Votes" {
                        VotesTabView()
                            .environmentObject(userVM)
                            .environmentObject(postVM)
                    } else if selectedTab == "Takes" {
                        TakesView()
                    } else if selectedTab == "Statistics" {
                        StatisticsView()
                            .environmentObject(userVM)
                            .environmentObject(postVM)
                    } else {
                        VStack {
                            Text("\(selectedTab) Content Here")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(10)
                                .padding()
                        }
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
                    .environmentObject(authVM)
            }
            .sheet(isPresented: $showingTakeTimeResults) {
                TakeTimeResultsView(myResponses: userVM.user.myTakeTime)
            }
        }
    }
}

struct ProfileTabButton: View {
    let title: String
    @Binding var selectedTab: String

    var body: some View {
        Button(action: {
            withAnimation {
                selectedTab = title
            }
        }) {
            VStack(spacing: 0) {
                Text(title)
                    .font(.system(size: 20))
                    .foregroundColor(selectedTab == title ? .black : .gray)
                    .fontWeight(selectedTab == title ? .bold : .regular)
                    .padding(.bottom, 6)
                
                if (selectedTab == title) {
                    Rectangle()
                        .frame(height: 4)
                        .cornerRadius(4)
                        .foregroundColor(.blue)
                        .edgesIgnoringSafeArea(.horizontal)
                }
            }
            .padding(.top, 8)
        }
        .padding(.horizontal, 5)
//        .frame(minWidth: 100)
    }
}
