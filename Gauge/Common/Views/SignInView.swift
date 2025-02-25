//
//  SignInView.swift
//  Gauge
//
//  Created by Datta Kansal on 2/6/25.
//

import SwiftUI
struct SignInView: View {
    @StateObject private var authVM = AuthenticationVM()
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        VStack {
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            if let errorMessage = authVM.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
            
            Button(action: {
                Task {
                    await authVM.signIn(email: email, password: password)
                }
            }) {
                if authVM.isLoading {
                    ProgressView()
                } else {
                    Text("Sign In")
                        .bold()
                    // add navigation here
                }
            }
            .padding()
        }
        .padding()
    }
}
