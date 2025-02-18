//
//  UserFirebase.swift
//  Gauge
//
//  Created by Austin Huguenard on 2/6/25.
//

import Foundation

class UserFirebase: ObservableObject {
    @Published var user: User = User(userId: "exampleUser", username: "exampleUser", email: "exuser@gmail.com")
    
    func getUserResponse() {
        // create variables to store subcollection info
        var responsePostIDs: [String] = []
        var commentPostIDs: [String] = []
        var viewPostIDs: [String] = []
        
        // traverse through POSTS collection
        Firebase.db.collection("POSTS").getDocuments { snapshot, error in
            if let documents = snapshot?.documents {
                for document in documents {
                    let documentRef = Firebase.db.collection("POSTS").document(document.documentID)
                    
                
                    let subcollections = ["RESPONSES", "COMMENTS", "VIEWS"]
                    
                    //traverse through subcollections
                    for subcollection in subcollections {
                        let currentSubcollection = subcollection
                        
                        documentRef.collection(currentSubcollection)
                            .whereField("userId", isEqualTo: self.user.userId)
                            .getDocuments { subSnapshot, subError in
                                
                                if let subDocuments = subSnapshot?.documents, !subDocuments.isEmpty {
                                    if currentSubcollection == "RESPONSES" {
                                        responsePostIDs.append(document.documentID)
                                    } else if currentSubcollection == "COMMENTS" {
                                        commentPostIDs.append(document.documentID)
                                    } else if currentSubcollection == "VIEWS" {
                                        viewPostIDs.append(document.documentID)
                                    }
                                }
                            }
                    }
                }
            }
            
            print("Responses: \(responsePostIDs)")
            print("Comments: \(commentPostIDs)")
            print("Views: \(viewPostIDs)")
        }
    }

    
    
}
