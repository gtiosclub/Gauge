//
//  Scheduler.swift
//  Gauge
//
//  Created by Dahyun on 3/24/25.
//

import SwiftUI
import Combine
import FirebaseFirestore

class Scheduler: ObservableObject {
    @Published var shouldInterrupt: Bool = false
    @Published var savedUserState: String?

    private let launchTime = Date()
    private var hasTriggered = false

    private var listener: ListenerRegistration?

    init() {
        startFirestoreListener()
    }

    func startFirestoreListener() {
        let db = Firestore.firestore()
        listener = db.collection("TakeTime")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                guard let snapshot = snapshot else {
                    print("Error listening for updates: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }

                for change in snapshot.documentChanges where change.type == .added {
                    if self.hasTriggered { break }

                    if let createdAt = change.document.data()["createdAt"] as? Timestamp,
                       createdAt.dateValue() > self.launchTime {
                        self.hasTriggered = true
                        print("triggered")
                        self.triggerInterrupt()
                        break
                    }
                }
            }
    }

    func stopFirestoreListener() {
        listener?.remove()
        listener = nil
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
