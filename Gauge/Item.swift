//
//  Item.swift
//  Gauge
//
//  Created by Austin Huguenard on 2/2/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
