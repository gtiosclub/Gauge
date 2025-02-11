//
//  HomeView.swift
//  Gauge
//
//  Created by Austin Huguenard on 2/6/25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var userVM: UserFirebase
    
    var body: some View {
        VStack {
            Text("Hello, \(userVM.user.username)!")
            
            NavigationLink("To Testing Screen") {
                FirebaseTesting()
            }
        }
    }
}

#Preview {
    HomeView()
}
