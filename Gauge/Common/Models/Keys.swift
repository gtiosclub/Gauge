//
//  Keys.swift
//  Gauge
//
//  Created by Austin Huguenard on 2/10/25.
//

import Foundation
import Firebase

class Keys {
    static var openAIKey: String = ""

    static func fetchKeys() {
        Firebase.db.collection("KEYS").document("OpenAI").getDocument { doc, error in
            if let document = doc, let data = document.data(), let key = data["key"] as? String {
                self.openAIKey = key
            } else {
                print("Error fetching keys: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
}
