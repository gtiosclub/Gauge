//
//  GameSettingsVM.swift
//  Gauge
//
//  Created by Nikola Cao on 2/11/25.
//

import SwiftUI

//game settings class so that the game settings can persist across views
class TakeMatchSettingsVM: ObservableObject {
    @Published var numRounds: Int = 3
    @Published var roundLen: Int = 30
    @Published var categories: [String] = []
    @Published var questions: [String] = []

}
