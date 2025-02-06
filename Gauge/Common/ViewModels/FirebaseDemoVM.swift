//
//  FirebaseInit.swift
//  Gauge
//
//  Created by Austin Huguenard on 2/2/25.
//

import Foundation
import Firebase

class FirebaseDemoVM: ObservableObject {
    @Published var users: [User] = []
    
    func addUserAustin() {
        Firebase.db.collection("USERS").document("austin").setData([
            "username": "Austin",
            "phoneNumber": "111-111-1111"
        ]) { error in
            if let error = error {
                print("error writing doc: \(error)")
            } else {
                print("added austin to USERS")
            }
        }
    }
    
    func addNewUser() {
        Firebase.db.collection("USERS").addDocument(data: [
            "username": "new user!",
            "phoneNumber": "\(Int.random(in: 0...9))\(Int.random(in: 0...9))\(Int.random(in: 0...9))-\(Int.random(in: 0...9))\(Int.random(in: 0...9))\(Int.random(in: 0...9))-\(Int.random(in: 0...9))\(Int.random(in: 0...9))\(Int.random(in: 0...9))\(Int.random(in: 0...9))"
        ]) { error in
            if let error = error {
                print("error writing doc: \(error)")
            } else {
                print("added new user to USERS")
            }
        }
    }
    
    func getAustinUser() {
        Firebase.db.collection("USERS").document("austin").getDocument { document, error in
            if let document = document, document.exists {
                if let data = document.data() {
                    print("User data: \(data)")
                    DispatchQueue.main.async {
                        self.users = []
                        self.users = [User(userId: "austin", username: data["username"] as? String ?? "No username", email: data["email"] as? String ?? "No email" )]
                        print("updated user array: \(self.users)")
                    }
                } else {
                    print("No data returned!")
                }
            } else {
                print("No such document")
            }
        }
    }
    
    func getUsers() {
        Firebase.db.collection("USERS").getDocuments { snapshot, error in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                var retrievedUsers: [User] = []
                for document in snapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    let retrievedUser = User(userId: document.documentID, username: document.data()["username"] as? String ?? "No username", email: document.data()["email"] as? String ?? "No email")
                    retrievedUsers.append(retrievedUser)
                }
                self.users = retrievedUsers
            }
        }
    }
    
    func updateAustinPhoneNumber() {
        Firebase.db.collection("USERS").document("austin").updateData([
            "phoneNumber": "222-222-2222"
        ]) { error in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Document successfully updated")
            }
        }
    }
    
    func deleteAustinUser() {
        Firebase.db.collection("USERS").document("austin").delete() { error in
            if let error = error {
                print("Error removing document: \(error)")
            } else {
                print("Document successfully removed!")
            }
        }
    }
    
    func configureGetLiveChanges() {
        Firebase.db.collection("USERS").addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot else {
                print("Error fetching updates: \(error!)")
                return
            }
            
            for change in snapshot.documentChanges {
                if change.type == .added {
                    print("Received new document: \(change.document.data())")
                    if self.users.filter({$0.userId == change.document.documentID}).isEmpty {
                        self.users.append(User(userId: change.document.documentID, username: change.document.data()["username"] as? String ?? "No username", email: change.document.data()["email"] as? String ?? "No email"))
                    }
                } else if change.type == .modified {
                    print("Received updated document: \(change.document.data())")
                } else if change.type == .removed {
                    print("Received deleted document: \(change.document.data())")
                }
            }
        }

    }
}
