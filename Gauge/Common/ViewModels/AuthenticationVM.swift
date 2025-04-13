//
//  AuthenticationVM.swift
//  Gauge
//
//  Created by Datta Kansal on 2/6/25.
//

@preconcurrency import FirebaseAuth

class AuthenticationVM: ObservableObject {
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published var currentUser: User?
    @Published var tempUser: User?
    @Published var onboardingState: OnboardingState = .welcome
    @Published var tempUserData = TempUserData()
    
    let auth = Auth.auth()
    
    enum OnboardingState {
        case welcome
        case email
        case username
        case password
        case gender
        case location
        case profileEmoji
        case bio
        case categories
        case attributes
        case complete
    }

    
    class TempUserData: ObservableObject {
        @Published var email: String = ""
        @Published var username: String = ""
        @Published var password: String = ""
        @Published var gender: String = ""
        @Published var location: String = ""
        @Published var profileEmoji: String = ""
        @Published var bio: String = ""
        @Published var selectedCategories: Set<String> = []
        @Published var attributes: [String: String] = [:]
    }

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
    
    func createInitialAccount() async throws {
        do {
            DispatchQueue.main.async {
                self.isLoading = true
            }
            let authResult = try await auth.createUser(withEmail: self.tempUserData.email, password: self.tempUserData.password)
            let user = authResult.user
            
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = tempUserData.username
            try await changeRequest.commitChanges()
            
            DispatchQueue.main.async {
                self.tempUser = User(userId: user.uid, username: self.tempUserData.username, email: self.tempUserData.email)
            }
            
            // Initialize with empty attributes map
            let initialAttributes: [String: String] = [:]
            
            let nowString = DateConverter.convertDateToString(Date())
            
            let userData = ["email": tempUserData.email,
                            "username": tempUserData.username,
                            "lastLogin": nowString,
                            "lastFeedRefresh": nowString,
                            "streak": 1,
                            "friendIn": [],
                            "friendOut": [],
                            "friends": [],
                            "badges": [],
                            "profilePhoto": "",
                            "phoneNumber": "",
                            "myCategories": [],
                            "myNextPosts": [],
                            "myProfileSearches": [],
                            "myPostSearches": [],
                            "myAccessedProfiles": [],
                            "attributes": initialAttributes] as [String : Any]
                                
                try await Firebase.db.collection("USERS").document(user.uid).setData(userData)
            
            DispatchQueue.main.async {
                self.isLoading = false
                self.onboardingState = .gender
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }

    func updateUserProfile() async throws {
        guard let userId = tempUser?.userId else { return }
        
        let userAttributes: [String: String] = [
            "gender": tempUserData.attributes["gender"] ?? "",
            "location": tempUserData.attributes["location"] ?? "",
            "profileEmoji": tempUserData.attributes["profileEmoji"] ?? "",
            "pronouns": tempUserData.attributes["pronouns"] ?? "",
            "age": tempUserData.attributes["age"] ?? "",
            "height": tempUserData.attributes["height"] ?? "",
            "relationshipStatus": tempUserData.attributes["relationshipStatus"] ?? "",
            "workStatus": tempUserData.attributes["workStatus"] ?? "",
            "bio": tempUserData.bio
        ]
        
        let updates: [String: Any] = [
            "attributes": userAttributes,
            "myCategories": Array(tempUserData.selectedCategories)
        ]
        
        try await Firebase.db.collection("USERS").document(userId).updateData(updates)
        
        tempUser?.attributes = userAttributes
        tempUser?.myCategories = Array(tempUserData.selectedCategories)
        
        DispatchQueue.main.async {
            self.currentUser = self.tempUser
        }
    }

    
    func signOut() {
        do {
            try auth.signOut()
            DispatchQueue.main.async {
                self.currentUser = nil
                self.onboardingState = .welcome
            }
        } catch {
            self.errorMessage = error.localizedDescription
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
