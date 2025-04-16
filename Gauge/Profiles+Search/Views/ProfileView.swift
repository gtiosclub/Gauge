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
                        VotesTabView(visitedUser: userVM.user, profileVM: profileViewModel)
                    } else if selectedTab == "Takes" {
                        TakesView(visitedUser: userVM.user, profileVM: profileViewModel)
                    } else if selectedTab == "Statistics" {
                        StatisticsView(
                            visitedUser: userVM.user,
                            totalVotes: userVM.user.myResponses.count,
                            totalComments: userVM.user.myComments.count,
                            totalTakes: userVM.user.myPosts.count,
                            viewResponseRatio: userVM.user.myResponses.count == 0 ? 0.0 :
                                Double(userVM.user.myViews.count) / Double(userVM.user.myResponses.count)
                        )
                    } else if selectedTab == "Comments" {
                        CommentsTabView(visitedUser: userVM.user)
                    } else if selectedTab == "Favorites" {
                        FavoritesTabView(visitedUser: userVM.user)
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
            .task {
                if profileViewModel.posts.isEmpty {
                    await profileViewModel.fetchRespondedPosts(for: userVM.user.userId, using: userVM)
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
                    .environmentObject(authVM)
            }
            .sheet(isPresented: $showingTakeTimeResults) {
                TakeTimeResultsView(user: userVM.user, myResponses: userVM.user.myTakeTime)
            }
        }
    }
    
//    struct TakeTimeResultsView: View {
//        let myResponses: [String: Int]
//        @State private var takes: [Take] = []
//        
//        var body: some View {
//            List {
//                ForEach(myResponses.sorted(by: { $0.key < $1.key }), id: \.key) { id, selectedOption in
//                    if let take = takes.first(where: { $0.id == id }) {
//                        VStack(alignment: .leading) {
//                            Text(take.question)
//                                .font(.headline)
//                            Text("Your choice: \(selectedOption == 1 ? take.responseOption1 : take.responseOption2)")
//                                .font(.subheadline)
//                                .foregroundColor(.blue)
//                        }
//                        .padding(.vertical, 6)
//                        TakeCard(username: user.username, profilePhotoURL: user.profilePhoto, timeAgo: "", tags: take.topic, content: take.question, votes: 0, comments: 0, views: 0)
//                    }
//                }
//            }
//            .navigationTitle("My TakeTime Results")
//            .onAppear {
//                fetchTakes()
//            }
//        }
        
//        func fetchTakes() {
//            let ids = Array(myResponses.keys)
//            
//            for id in ids {
//                Firebase.db.collection("TakeTime").document(id).getDocument { document, error in
//                    if let document = document,
//                       let take = try? document.data(as: Take.self) {
//                        DispatchQueue.main.async {
//                            takes.append(take)
//                        }
//                    }
//                }
//            }
//        }
//    }
    
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
}
