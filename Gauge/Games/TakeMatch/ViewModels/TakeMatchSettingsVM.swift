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
    
}
