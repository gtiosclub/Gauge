//
//  SignUpView.swift
//  Gauge
//
//  Created by Datta Kansal on 2/6/25.
//
import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authVM: AuthenticationVM
    @State private var email = ""
    @State private var password = ""
    @State private var username = ""
    
    var body: some View {
        VStack {
            TextField("Username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
            
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
                    await authVM.signUp(email: email, password: password, username: username)
                }
            }) {
                if authVM.isLoading {
                    ProgressView()
                } else {
                    Text("Sign Up")
                        .bold()
                    // add navigation here
                }
            }
            .padding()
        }
        .padding()
    }
}
