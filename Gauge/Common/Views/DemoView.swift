//
//  DemoView.swift
//  Gauge
//
//  Created by Austin Huguenard on 2/2/25.
//

import SwiftUI
import SwiftData

struct DemoView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject var firebaseVM = FirebaseDemoVM()
    @StateObject var postVM = PostFirebase()

    var body: some View {
        VStack(spacing: 20) {
            
            Section("Write Data") {
                Button("Add User Austin") {
                    firebaseVM.addUserAustin()
                }
                
                Button("Add new User") {
                    firebaseVM.addNewUser()
                }
                
                // Krish Tests
                Button("Add Binary Post") {
                    postVM.createBinaryPost(
                        userId: "tfeGCRCgt8UbJhCmKgNmuIFVzD73",
                        category: .food,
                        question: "Is pizza the goat food?",
                        responseOption1: "yes",
                        responseOption2: "no"
                    )
                }
                
                Button("Add Slider Post") {
                    postVM.createSliderPost(
                        userId: "xEZWt93AaJZPwfHAjlqMjmVP0Lz1",
                        category: .tech,
                        question: "rate Swift 1-10",
                        lowerBoundValue: 1,
                        upperBoundValue: 10,
                        lowerBoundLabel: "Terrible 🤮",
                        upperBoundLabel: "Goated 🐐")
                }
            }
            
            Section("Get Live Data (Great for feed & games!)") {
                Button("Watch for changes") {
                    firebaseVM.configureGetLiveChanges()
                }
            }
            
            Section("Read Data") {
                Button("Get Austin User") {
                    firebaseVM.getAustinUser()
                }
                
                Button("Get All Users") {
                    firebaseVM.getUsers()
                }
            }
            
            Section("Update Data") {
                Button("Update Austin Phone Number") {
                    firebaseVM.updateAustinPhoneNumber()
                }
                
                Button("Delete austin User") {
                    firebaseVM.deleteAustinUser()
                }
            }
            
            Section("View Data") {
                ScrollView {
                    ForEach(firebaseVM.users, id: \.id) { user in
                        HStack {
                            Text("\(user.userId): \(user.username) \(user.phoneNumber)")
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    DemoView()
}
