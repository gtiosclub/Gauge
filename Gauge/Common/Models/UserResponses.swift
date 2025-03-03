//
//  UserResponses.swift
//  Gauge
//
//  Created by Kavya Adusumilli on 2/27/25.
//

import Foundation
import SwiftData
class UserResponses {
    var userResponses: [String : Int] // String is Category name .rawValue, Int is number of times interacted in session
    var currentUserCategories: [String] // Current category list (as rawValues) in Firebase
    init(userResponses: [String : Int], currentUserCategories: [String]) {
        self.userResponses = userResponses
        self.currentUserCategories = currentUserCategories
    }
    
}
    //container is where data is persisted.. create in separate file

