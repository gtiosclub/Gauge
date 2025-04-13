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
    @State var isCurrentUser: Bool
    let userTags = ["📏5'9", "📍Atlanta", "🔒Single", "🎓College"]
    @State private var profileImage: UIImage?
    let tabs = ["Takes", "Votes", "Comments", "Badges", "Statistics", "Favorites"]
    @State var slideGesture: CGSize = .zero
    @State var currTabIndex = 0
    var distance: CGFloat = UIScreen.main.bounds.size.width

    var body: some View {
        NavigationStack {
            VStack {
                if isCurrentUser {
                    HStack {
                        Spacer()
                        Menu {
                            NavigationLink(destination: ProfileEditView()) {
                                Label("Profile", systemImage: "person")
                            }
                            Button(action: { showingSettings = true }) {
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
                    .padding(.leading, 16)
                    HStack(spacing: 16) {
                        ZStack {
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
                            Button(action: { showingTakeTimeResults = true }) {
                                Circle()
                                    .foregroundColor(Color.black.opacity(0.25))
                                    .frame(width: 80, height: 80)
                                    .overlay(
                                        Image(systemName: "chart.bar")
                                            .foregroundColor(.white)
                                    )
                            }
                        }
                        VStack(alignment: .leading, spacing: 8) {
                            Text(userVM.user.username)
                                .font(.system(size: 30))
                                .fontWeight(.medium)
                            NavigationLink(destination: FriendsView()) {
                                HStack {
                                    Text("27")
                                        .foregroundColor(.black)
                                    Text("Friends")
                                        .foregroundColor(Color(.systemGray))
                                }
                            }
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
                        }
                        Spacer()
                    }
                    .padding()
                }
                if !isCurrentUser {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(userVM.user.username)
                                .font(.system(size: 30))
                                .fontWeight(.medium)
                            NavigationLink(destination: FriendsView()) {
                                HStack {
                                    Text("27")
                                        .foregroundColor(.black)
                                    Text("Friends")
                                        .foregroundColor(Color(.systemGray))
                                }
                            }
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
                        }
                        Spacer()
                    }
                    .padding(.top, 15)
                }
                HStack {
                    Text("a short bio that describes the user")
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
                GeometryReader { geo in
                    HStack(spacing: 0) {
                        TakesView()
                            .frame(width: geo.size.width)
                        VoteCardsView()
                            .frame(width: geo.size.width)
                        TabPlaceholder(tab: "Comments")
                            .frame(width: geo.size.width)
                        BadgesView(onBadgeTap: { badge in
                            selectedBadge = badge
                        })
                            .frame(width: geo.size.width)
                        StatisticsDetailedView()
                            .frame(width: geo.size.width)
                        TabPlaceholder(tab: "Favorites")
                            .frame(width: geo.size.width)
                    }
                    .offset(x: -CGFloat(currTabIndex) * geo.size.width + slideGesture.width)
                    .animation(.spring(), value: currTabIndex)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                slideGesture = value.translation
                            }
                            .onEnded { value in
                                let threshold: CGFloat = 50
                                if value.translation.width < -threshold, currTabIndex < tabs.count - 1 {
                                    currTabIndex += 1
                                    selectedTab = tabs[currTabIndex]
                                } else if value.translation.width > threshold, currTabIndex > 0 {
                                    currTabIndex -= 1
                                    selectedTab = tabs[currTabIndex]
                                }
                                slideGesture = .zero
                            }
                    )
                }
            }
            .onChange(of: selectedTab) { newValue in
                if let index = tabs.firstIndex(of: newValue) {
                    withAnimation { currTabIndex = index }
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

struct StatisticsDetailedView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Username Statistics")
                .font(.system(size: 21))
                .fontWeight(.bold)
                .padding(.vertical, 20)
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .center)
            VStack(spacing: 0) {
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
        }
    }
}

struct TabButton: View {
    let title: String
    @Binding var selectedTab: String

    var body: some View {
        Button(action: {
            withAnimation { selectedTab = title }
        }) {
            VStack(spacing: 0) {
                Text(title)
                    .font(.system(size: 20))
                    .foregroundColor(selectedTab == title ? .black : .gray)
                    .fontWeight(selectedTab == title ? .bold : .regular)
                    .padding(.bottom, 6)
                if selectedTab == title {
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

struct TabPlaceholder: View {
    var tab: String

    var body: some View {
        VStack {
            Text("\(tab) Content Here")
                .font(.subheadline)
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(UIColor.systemGray6))
        }
        .cornerRadius(10)
        .padding()
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
