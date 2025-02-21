import SwiftUI

struct FriendsView: View {
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                SearchBar(text: $searchText)
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .frame(height: 36)
                
                Divider()
                    .padding(.horizontal)
                    .padding(.top, 8)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        SectionHeader(title: "Requests")
                            .padding(.top, 16)
                        FriendRequestView()
                            .padding(.bottom, 8)
                        
                        HStack(spacing: -8) {
                            ForEach(0..<4) { _ in
                                Circle()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(Color(.systemGray3))
                            }
                            Text("  and 4 others...")
                                .font(.subheadline)
                                .foregroundColor(.black)
                                .padding(.leading, 6)
                        }
                        .padding(.horizontal)
                        .padding(.top, -8)
                        
                        SectionHeader(title: "27 Friends")
                            .padding(.top, 16)
                        FriendsListView()
                    }
                }
            }
            .navigationBarTitle("Friends", displayMode: .inline)
            .navigationBarItems(leading: Button("Profile") {})
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("Search", text: $text)
                .frame(height: 36)
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .frame(height: 28)
            
            Image(systemName: "mic.fill")
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.headline)
            .fontWeight(.bold)
            .padding(.horizontal)
    }
}

struct FriendRequestView: View {
    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .frame(width: 30, height: 30)
                .foregroundColor(Color(.systemGray3))
            Text("username")
            Spacer()
            Button("Accept") {
                
            }
            .font(.system(size: 16, weight: .bold))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(6)
            
            Button(action: {}) {
                Image(systemName: "xmark")
                    .frame(width: 20, height: 15)
                    .padding(6)
                    .foregroundColor(.gray)
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(4)
            }
        }
        .padding(.horizontal)
    }
}

struct FriendsListView: View {
    var body: some View {
        ForEach(0..<10) { _ in
            HStack(spacing: 10) {
                Circle()
                    .frame(width: 30, height: 30)
                    .foregroundColor(Color(.systemGray3))
                Text("username")
                Spacer()
                Button(action: {}) {
                    Image(systemName: "xmark")
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    FriendsView()
}
