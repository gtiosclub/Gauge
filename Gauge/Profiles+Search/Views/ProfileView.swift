import SwiftUI

struct ProfileView: View {
    @ObservedObject var userVM: UserFirebase
    @EnvironmentObject var postVM: PostFirebase // will need to be changed to observed object and passed in on ContentView (like userVM) when postVM is actually used to display posts on profiles
    @State private var selectedTab: String = "Takes"
    @State private var selectedBadge: BadgeModel? = nil
    @State var isCurrentUser: Bool
    
    let userTags = ["📏5'9", "📍Atlanta", "🔒Single", "🎓College"]

    var body: some View {
        NavigationStack {
            VStack {
                
                // Edit Profile, Settings
                if isCurrentUser {
                    HStack {
                        Spacer()
                        Menu {
                            NavigationLink(destination: ProfileEditView()) {
                                Label("Profile", systemImage: "person")
                            }
                            
                            NavigationLink(destination: SettingsView()) {
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

                // Profile Picture, Username, Friends
                HStack {
                    HStack {
                        if let url = URL(string: userVM.user.profilePhoto), !userVM.user.profilePhoto.isEmpty {
                            AsyncImage(url: url) { phase in
                                if let image = phase.image {
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 60, height: 60)
                                        .clipShape(Circle())
                                } else if phase.error != nil {
                                    Circle()
                                        .fill(Color.gray)
                                        .frame(width: 60, height: 60)
                                } else {
                                    ProgressView()
                                        .frame(width: 60, height: 60)
                                }
                            }
                        } else {
                            Circle()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.leading, 16)
                    
                    VStack(alignment: .leading) {
                        // Display the username from the environment user.
                        Text(userVM.user.username)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        NavigationLink(destination: FriendsView()) {
                            Text("27")
                                .foregroundColor(.black)
                            Text("Friends")
                                .foregroundColor(Color(.systemGray))
                        }
                    }
                    
                    Spacer()
                }
                .padding(.top, isCurrentUser ? 0 : 10)
                
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
                            TabButton(title: "Takes", selectedTab: $selectedTab)
                            Spacer()
                            TabButton(title: "Votes", selectedTab: $selectedTab)
                            Spacer()
                            TabButton(title: "Comments", selectedTab: $selectedTab)
                            Spacer()
                            TabButton(title: "Badges", selectedTab: $selectedTab)
                            Spacer()
                            TabButton(title: "Statistics", selectedTab: $selectedTab)
                            Spacer()
                            TabButton(title: "Favorites", selectedTab: $selectedTab)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top, 5)
                    
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(Color(.systemGray))
                        .ignoresSafeArea(.container, edges: .horizontal)
                }
                .background(.red)
                
                HStack {
                    // Content based on the selected tab.
                    if selectedTab == "Badges" {
                        BadgesView(onBadgeTap: { badge in
                            selectedBadge = badge
                        })
                    } else if selectedTab == "Votes" {
                        VoteCardsView()
                    } else if selectedTab == "Takes" {
                        TakesView()
                    }
                    else if selectedTab == "Statistics" {
                        StatisticsView()
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

struct SettingsView: View {
    var body: some View {
        Text("Settings Screen")
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
    }
}

struct VoteCardsView: View {
    var body: some View {
        ScrollView {
            VStack {
                VoteCard(username: "User1", timeAgo: "1 hour ago", tags: ["swiftui", "ios"], vote: "Yes", content: "This is a sample vote card content.", comments: 10, views: 100, votes: 25)
                VoteCard(username: "User2", timeAgo: "2 hours ago", tags: ["programming", "swift"], vote: "No", content: "Another vote card example.", comments: 5, views: 50, votes: 10)
            }
            .padding()
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(userVM: UserFirebase(), isCurrentUser: false)
            .environmentObject(PostFirebase())
    }
}
