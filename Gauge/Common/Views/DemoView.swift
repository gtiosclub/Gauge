//
//  DemoView.swift
//  Gauge
//
//  Created by Austin Huguenard on 2/2/25.
//

import SwiftUI
import SwiftData

struct DemoView: View {
    @StateObject var firebaseVM = FirebaseDemoVM()
    @StateObject var userVM = UserFirebase()

    var body: some View {
        VStack(spacing: 20) {
            
            Section("Write Data") {
                Button("Add User Austin") {
                    firebaseVM.addUserAustin()
                }
                
                Button("Add new User") {
                    firebaseVM.addNewUser()
                }
                
                Button("add user search") {
                    userVM.addUserSearch(
                        userId: "2kDjg6AEanY2raJDnDgqb76M6dn1",
                        search: "food"
                    )
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
