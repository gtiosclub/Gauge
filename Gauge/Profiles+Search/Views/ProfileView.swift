import SwiftUI

struct ProfileView: View {
    @ObservedObject var userVM: UserFirebase
    @EnvironmentObject var postVM: PostFirebase
    @EnvironmentObject var authVM: AuthenticationVM
    @StateObject var profileViewModel = ProfileViewModel()
    @State private var selectedTab: String = "Takes"
    @State private var selectedBadge: BadgeModel? = nil
    @State private var showingSettings = false
    let isCurrentUser: Bool
    
    let userTags = ["📏5'9", "📍Atlanta", "🔒Single", "🎓College"]
    @State private var profileImage: UIImage?

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    // Profile Header with Settings Button
                    HStack {
                        Spacer()
                        if isCurrentUser {
                            Button(action: {
                                showingSettings = true
                            }) {
                                Image(systemName: "gearshape.fill")
                                    .foregroundColor(.gray)
                            }
                            .padding(.trailing)
                        }
                    }
                    
                    HStack {
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

                        VStack(alignment: .leading) {
                            // Display the username from the environment user.
                            Text(userVM.user.username)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            NavigationLink(destination: FriendsView()) {
                                Image(systemName: "person.2.fill")
                                    .foregroundColor(.gray)
                                Text("27")
                                    .foregroundColor(.black)
                            }
        
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 20) {
                                    ForEach(userTags, id: \.self) { tag in
                                        Text(tag)
                                            .padding(.horizontal, 15)
                                            .padding(.vertical, 6)
                                            .font(.system(size: 14))
                                            .background(Color.gray.opacity(0.2))
                                            .foregroundColor(.black)
                                        .cornerRadius(10)}
                                }
                            }
                            
                            Text("a short bio that describes the user")
                             
                        }
                        
                        Text("i have many hot takes to make")
                    }
                    .padding()

                   
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
                    .padding(.top, 10)

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
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Username Statistics")
                                .font(.system(size:21))
                                .fontWeight(.bold)
                                .padding(.vertical, 20)
                                .padding(.horizontal)
                                .frame(maxWidth: .infinity, alignment: .center)
                            
                            VStack(spacing: 0) {
                                // Total Votes Made
                                HStack {
                                    Text("Total Votes Made")
                                        .font(.system(size: 17))
                                        .fontWeight(.regular)
                                    Spacer()
                                    HStack {
                                        Text("100 Votes")
                                            .font(.system(size: 17))
                                            .foregroundColor(.gray)
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.gray)
                                            .font(.system(size: 14))
                                    }
                                }
                                .padding(.vertical, 15)
                                .padding(.horizontal)
                                
                                Divider().padding(.horizontal)
                                
                                // Total Takes Made
                                HStack {
                                    Text("Total Takes Made")
                                        .font(.system(size: 17))
                                        .fontWeight(.regular)
                                    Spacer()
                                    HStack {
                                        Text("25 Takes")
                                            .font(.system(size: 17))
                                            .foregroundColor(.gray)
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.gray)
                                            .font(.system(size: 14))
                                    }
                                }
                                .padding(.vertical, 15)
                                .padding(.horizontal)
                                
                                Divider().padding(.horizontal)
                                
                                // Total Votes Collected
                                HStack {
                                    Text("Total Votes Collected")
                                        .font(.system(size: 17))
                                        .fontWeight(.regular)
                                    Spacer()
                                    HStack {
                                        Text("275 Votes")
                                            .font(.system(size: 17))
                                            .foregroundColor(.gray)
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.gray)
                                            .font(.system(size: 14))
                                    }
                                }
                                .padding(.vertical, 15)
                                .padding(.horizontal)
                                
                                Divider().padding(.horizontal)
                                
                                HStack {
                                    Text("Total Comments Made")
                                        .font(.system(size: 17))
                                        .fontWeight(.regular)
                                    Spacer()
                                    HStack {
                                        Text("110 Comments")
                                            .font(.system(size: 17))
                                            .foregroundColor(.gray)
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.gray)
                                            .font(.system(size: 14))
                                    }
                                }
                                .padding(.vertical, 15)
                                .padding(.horizontal)
                                
                                Divider().padding(.horizontal)
                                
                                HStack {
                                    Text("Ratio View/Response")
                                        .font(.system(size: 17))
                                        .fontWeight(.regular)
                                    Spacer()
                                    HStack {
                                        Text("0.75")
                                            .font(.system(size: 17))
                                            .foregroundColor(.gray)
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.gray)
                                            .font(.system(size: 14))
                                    }
                                }
                                .padding(.vertical, 15)
                                .padding(.horizontal)
                            }
                            Spacer()
                        }
                        .background(Color.white)
                        .cornerRadius(10)
                        .padding([.horizontal, .bottom])
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

                    // Display other attributes
                    ForEach(Array(userVM.user.attributes.keys), id: \.self) { key in
                        if key != "profileEmoji" { // Don't show profileEmoji in attributes list
                            HStack {
                                Text(key.capitalized)
                                    .bold()
                                Spacer()
                                Text(userVM.user.attributes[key] ?? "")
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if isCurrentUser {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: ProfileEditView()) {
                            Text("edit profile")
                                .font(.system(size: 15))
                        }
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
                    .environmentObject(authVM)
            }
            .sheet(item: $selectedBadge) { badge in
                BadgeDetailView(badge: badge)
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
                    .font(.system(size: 25))
                    .foregroundColor(selectedTab == title ? .black : .gray)
                    .fontWeight(selectedTab == title ? .bold : .regular)
                Rectangle()
                    .frame(height: 2)
                    .foregroundColor(selectedTab == title ? .blue : .gray)
                    .edgesIgnoringSafeArea(.horizontal)
            }
            .padding(.vertical, 8)
        }
        .frame(minWidth: 100)
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
            .environmentObject(AuthenticationVM())
    }
}
