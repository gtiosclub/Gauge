//
//  GameSettingsVM.swift
//  Gauge
//
//  Created by Nikola Cao on 2/11/25.
//

import SwiftUI

//game settings class so that the game settings can persist across views
class TakeMatchSettingsVM: ObservableObject {
    static let shared = TakeMatchSettingsVM()
    @Published var numRounds: Int = 3
    @Published var roundLen: Int = 30
    @Published var selectedCategories: [String] = []
    @Published var questionOptions: [String] = []
    @Published var question: String = ""
    @Published var selectedTopic: String = "No topic selected"

    private init() {}
}

