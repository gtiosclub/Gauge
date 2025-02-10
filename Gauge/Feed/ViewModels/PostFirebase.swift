//
//  PostFirebase.swift
//  Gauge
//
//  Created by Austin Huguenard on 2/6/25.
//

import Foundation

class PostFirebase: ObservableObject {
    @Published var feedPosts: [Post] = []
    @Published var allQueriedPosts: [Post] = []
    
    
}
