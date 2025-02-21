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
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        SectionHeader(title: "Requests")
                            .padding(.top, 16)
                        FriendRequestView()
                            .padding(.bottom, 16)
                        
                        HStack(spacing: -10) {
                            ForEach(0..<4) { _ in
                                Circle()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(Color(.systemGray3))
                            }
                            Text(" and 4 others...")
                                .font(.subheadline)
                                .foregroundColor(.black)
                                .padding(.leading, 10)
                        }
                        .padding(.horizontal)
                        
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
            TextField("Search", text: $text)
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .frame(height: 30)
            
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
        HStack {
            Circle()
                .frame(width: 36, height: 36)
                .foregroundColor(Color(.systemGray3))
            Text("username")
            Spacer()
            Button("Accept") {
                
                
            }
            .padding(.horizontal, 8)
            .font(.system(size: 16, weight: .bold))
            .padding(.vertical, 4)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(6)
            
            Button(action: {}) {
                            Image(systemName: "xmark")
                                .foregroundColor(.gray)
                                .frame(width: 20, height: 16)
                                .padding(6)
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
            HStack {
                Circle()
                    .frame(width: 36, height: 36)
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
