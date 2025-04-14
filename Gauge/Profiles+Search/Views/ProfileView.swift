import SwiftUI
import Firebase

struct ProfileView: View {
    @ObservedObject var userVM: UserFirebase
    @EnvironmentObject var postVM: PostFirebase
    @EnvironmentObject var authVM: AuthenticationVM
    @StateObject var profileViewModel = ProfileViewModel()
    @State private var selectedTab: String = "Takes"
    @State private var selectedBadge: BadgeModel? = nil
    @State private var showingTakeTimeResults = false
    @State private var showingSettings = false
    let isCurrentUser: Bool

    let userTags = ["📏5'9", "📍Atlanta", "🔒Single", "🎓College"]
    @State private var profileImage: UIImage?
    let tabs = ["Takes", "Votes", "Comments", "Badges", "Statistics", "Favorites"]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    
                    // Edit Profile, Settings
                    if isCurrentUser {
                        HStack {
                            Spacer()
                            Menu {
                                NavigationLink(destination: ProfileEditView()) {
                                    Label("Profile", systemImage: "person")
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
                                    .padding()
                            }
                        }
                    }

                    HStack {
                        ZStack {
                            // CHANGED: Get emoji from attributes
                            if let emoji = userVM.user.attributes["profileEmoji"], !emoji.isEmpty {
                                Text(emoji)
                                    .font(.system(size: 60))
                            } else if let profileImage = profileImage {
                                Image(uiImage: profileImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 80, height: 80)
                                    .clipShape(Circle())
                            } else if let url = URL(string: userVM.user.profilePhoto), !userVM.user.profilePhoto.isEmpty {
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
                            }.disabled(userVM.user.myTakeTime.isEmpty)
                        }
                        .padding(.leading, 16)

                        VStack(alignment: .leading) {
                            // Display the username from the environment user.
                            Text(userVM.user.username)
                                .font(.system(size: 30))
                                .fontWeight(.medium)
                            
                            NavigationLink(destination: FriendsView(viewModel: FriendsViewModel( user: userVM.user), currentUser: userVM.user)) {
                                Text("\(userVM.user.friends.count)")
                                    .foregroundColor(.black)
                                Text("Friends")
                                    .foregroundColor(Color(.systemGray))
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.top, isCurrentUser ? 0 : 15)
                    
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
                    
                    //Bio
                    
                    HStack {
                        Text("a short bio that describes the user")
                            .padding(.leading, 20)
                        Spacer()
                    }
                    .padding(.top, 10)
                    
                    // Tabs
                    VStack (spacing: 0) {
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
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(Color(UIColor.systemGray6))
                        }
                        .cornerRadius(10)
                        .padding()
                    }

                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
                    .environmentObject(authVM)
            }
        }
    }
}

struct TakeTimeResultsView: View {
    let myResponses: [String: Int]
    @State private var takes: [Take] = []

    var body: some View {
        List {
            ForEach(myResponses.sorted(by: { $0.key < $1.key }), id: \.key) { id, selectedOption in
                if let take = takes.first(where: { $0.id == id }) {
                    VStack(alignment: .leading) {
                        Text(take.question)
                            .font(.headline)
                        Text("Your choice: \(selectedOption == 1 ? take.responseOption1 : take.responseOption2)")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    }
                    .padding(.vertical, 6)
                }
            }
        }
        .navigationTitle("My TakeTime Results")
        .onAppear {
            fetchTakes()
        }
    }

    func fetchTakes() {
        let db = Firestore.firestore()
        let ids = Array(myResponses.keys)

        for id in ids {
            db.collection("TakeTime").document(id).getDocument { document, error in
                if let document = document,
                   let take = try? document.data(as: Take.self) {
                    DispatchQueue.main.async {
                        takes.append(take)
                    }
                }
            }
        }
    }
}

struct TabButton: View {
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

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(userVM: UserFirebase(), isCurrentUser: false)
            .environmentObject(PostFirebase())
            .environmentObject(AuthenticationVM())
            .environmentObject(UserFirebase())
    }
}
