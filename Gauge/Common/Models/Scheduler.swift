//
//  Scheduler.swift
//  Gauge
//
//  Created by Dahyun on 3/24/25.
//

import SwiftUI
import Combine

class Scheduler: ObservableObject {
    @Published var shouldInterrupt: Bool = false
    @Published var savedUserState: String?

    private var timer: Timer?

    init() {
        startDailyInterruptTimer()
    }

    func startDailyInterruptTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            self.triggerInterrupt()
        }
    }

    private func checkForInterrupt() {
        let calendar = Calendar.current
        let currentTime = Date()
        let targetTime = calendar.date(bySettingHour: 17, minute: 18, second: 0, of: currentTime)! //Change this to when you want to trigger take time

        if calendar.isDate(currentTime, equalTo: targetTime, toGranularity: .minute) {
            triggerInterrupt()
        }
    }
    
    private func triggerInterrupt() {
        DispatchQueue.main.async {
            self.saveUserState()
            self.shouldInterrupt = true
            print("Interruption triggered after 1 minute!")
        }
    }

    func saveUserState() {
    }

    func restoreUserState() {
        shouldInterrupt = false
    }
}

