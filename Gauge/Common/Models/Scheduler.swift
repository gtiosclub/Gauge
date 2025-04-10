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
        // if testing with simulator:
        // startDailyInterruptTimer()
        // if testing on device:
        observeFCMInterrupt()
    }

    func startDailyInterruptTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { _ in
            self.checkForInterrupt()
        }
    }

    private func checkForInterrupt() {
        let calendar = Calendar.current
        let currentTime = Date()
        let targetTime = calendar.date(bySettingHour: 14, minute: 10, second: 0, of: currentTime)! // update designated take time

        if calendar.isDate(currentTime, equalTo: targetTime, toGranularity: .minute) {
            triggerInterrupt()
        }
    }

    func triggerInterrupt() {
        DispatchQueue.main.async {
            self.saveUserState()
            self.shouldInterrupt = true
            print("Interruption triggered!")
        }
    }

    func saveUserState() {

    }

    func restoreUserState() {
        shouldInterrupt = false
    }

    private func observeFCMInterrupt() {
        NotificationCenter.default.addObserver(forName: .triggerInterruptFromFCM, object: nil, queue: .main) { _ in
            self.triggerInterrupt()
        }
    }
}
