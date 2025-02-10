//
//  UserFirebase.swift
//  Gauge
//
//  Created by Austin Huguenard on 2/6/25.
//

import Foundation

class UserFirebase: ObservableObject {
    @Published var user: User = User(userId: "exampleUser", username: "exampleUser", email: "exuser@gmail.com")
    
    
}
