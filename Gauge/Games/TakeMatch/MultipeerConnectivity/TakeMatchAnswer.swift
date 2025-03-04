//
//  TakeMatchAnswer.swift
//  Gauge
//
//  Created by Nikola Cao on 2/26/25.
//

import Foundation

struct Answer: Identifiable, Codable {
    
    let id = UUID()
    let sender: String
    let text: String
}
