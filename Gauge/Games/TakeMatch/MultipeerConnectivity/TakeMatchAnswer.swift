//
//  TakeMatchAnswer.swift
//  Gauge
//
//  Created by Nikola Cao on 2/26/25.
//

import Foundation

struct Answer: Identifiable, Codable {
    var id = UUID()
    let sender: String
    let text: String
}

struct Vote: Codable {
    let question: String
    let sender: String
}
