//
//  AuthenticationVM.swift
//  Gauge
//
//  Created by Datta Kansal on 2/6/25.
//

import FirebaseAuth

class AuthenticationVM: ObservableObject {
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published var currentUser: User?
    
    let auth = Auth.auth()
    
    init() {
        auth.addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                if let user = user {
                    self?.fetchUser(userId: user.uid, email: user.email ?? "", username: user.displayName ?? "")
                } else {
                    self?.currentUser = nil
                }
            }
        }
    }
    
    func signUp(email: String, password: String, username: String) async {
        isLoading = true
        do {
            let authResult = try await auth.createUser(withEmail: email, password: password)
            let user = authResult.user
            
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = username
            try await changeRequest.commitChanges()
            
//            let userData = ["email": email, "username": username]
            
            let tempUser = User(userId: user.uid, username: username, email: email)
            
            let userData = ["email": email,
                            "username": username,
                            "lastLogin": DateConverter.convertDateToString(tempUser.lastLogin),
                            "lastFeedRefresh": DateConverter.convertDateToString(tempUser.lastFeedRefresh),
                            "streak": tempUser.streak,
                            "friendIn": tempUser.friendIn,
                            "friendOut": tempUser.friendOut,
                            "friends": tempUser.friends,
                            "badges": tempUser.badges,
                            "profilePhoto": tempUser.profilePhoto,
                            "phoneNumber": tempUser.phoneNumber,
                            "myCategories": tempUser.myCategories,
                            "myNextPosts": tempUser.myNextPosts,
                            "myPostSearches": tempUser.myPostSearches,
                            "myProfileSearches": tempUser.myProfileSearches,
                            "myAccessedProfiles": tempUser.myAccessedProfiles,
                            "myTakeTime": tempUser.myTakeTime

            ] as [String : Any]
            
            try await Firebase.db.collection("USERS").document(user.uid).setData(userData)
            
            DispatchQueue.main.async {
                self.currentUser = tempUser
                self.isLoading = false
                print("Signed up as \(username)")
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    func signIn(email: String, password: String) async {
        isLoading = true
        do {
            let authResult = try await auth.signIn(withEmail: email, password: password)
            let user = authResult.user
            
            DispatchQueue.main.async {
                self.fetchUser(userId: user.uid, email: email, username: user.displayName ?? "")
                self.isLoading = false
                print("Signed in up as \(user.displayName ?? "Anonymous")")
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    private func fetchUser(userId: String, email: String, username: String) {
        Task {
            do {
                let document = try await Firebase.db.collection("USERS").document(userId).getDocument()
                DispatchQueue.main.async {
                    if document.exists {
                        self.currentUser = User(userId: userId, username: username, email: email)
                    } else {
                        self.errorMessage = "User not found. Creating record."
                        Task { try await Firebase.db.collection("USERS").document(userId).setData(["email": email, "username": username]) }
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to fetch user data: \(error.localizedDescription)"
                }
            }
        }
    }
}
