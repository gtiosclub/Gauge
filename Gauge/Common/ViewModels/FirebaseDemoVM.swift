//
//  FirebaseInit.swift
//  Gauge
//
//  Created by Austin Huguenard on 2/2/25.
//

import Foundation
import Firebase

class FirebaseDemoVM: ObservableObject {
    let db = Firestore.firestore()
    @Published var users: [User] = []
    
    func addUserAustin() {
        db.collection("USERS").document("austin").setData([
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
        db.collection("USERS").addDocument(data: [
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
        db.collection("USERS").document("austin").getDocument { document, error in
            if let document = document, document.exists {
                if let data = document.data() {
                    print("User data: \(data)")
                    DispatchQueue.main.async {
                        self.users = []
                        self.users = [User(userId: "austin", username: data["username"] as? String ?? "No username", phoneNumber: data["phoneNumber"] as? String ?? "000-000-0000" )]
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
        db.collection("USERS").getDocuments { snapshot, error in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                var retrievedUsers: [User] = []
                for document in snapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    let retrievedUser = User(userId: document.documentID, username: document.data()["username"] as? String ?? "No username", phoneNumber: document.data()["phoneNumber"] as? String ?? "No phone number")
                    retrievedUsers.append(retrievedUser)
                }
                self.users = retrievedUsers
            }
        }
    }
    
    func updateAustinPhoneNumber() {
        db.collection("USERS").document("austin").updateData([
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
        db.collection("USERS").document("austin").delete() { error in
            if let error = error {
                print("Error removing document: \(error)")
            } else {
                print("Document successfully removed!")
            }
        }
    }
    
    func configureGetLiveChanges() {
        db.collection("USERS").addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot else {
                print("Error fetching updates: \(error!)")
                return
            }
            
            for change in snapshot.documentChanges {
                if change.type == .added {
                    print("Received new document: \(change.document.data())")
                    if self.users.filter({$0.userId == change.document.documentID}).isEmpty {
                        self.users.append(User(userId: change.document.documentID, username: change.document.data()["username"] as? String ?? "No username", phoneNumber: change.document.data()["phoneNumber"] as? String ?? "No phone number"))
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
