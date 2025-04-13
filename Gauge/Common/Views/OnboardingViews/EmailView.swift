//
//  CreateAccountView.swift
//  Gauge
//
//  Created by Anthony Le on 4/3/25.
//

import SwiftUI

struct EmailView: View {
    @EnvironmentObject var authVM: AuthenticationVM
    @State private var email: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            ProgressBar(progress: 1, steps: 3)
            
            ZStack {
                HStack {
                    Button(action: {
                        authVM.onboardingState = .welcome
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.blue)
                    }
                    Spacer()
                }
                Text("Create Account")
                    .font(.system(size: 17, weight: .semibold))
            }
            .padding(.top, 12)
            .padding(.horizontal, 18)
            
            Spacer().frame(height: 30)
            
            // Email field
            VStack(alignment: .leading, spacing: 8) {
                Text("What’s your email?")
                    .font(.title)
                    .bold()
                    .padding(.bottom, 20)
                
                TextField("Email", text: $email)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                    )
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            Button(action: {
                authVM.tempUserData.email = email
                authVM.onboardingState = .username
            }) {
                HStack {
                    Spacer()
                    Text("Next")
                        .foregroundColor(.white)
                        .bold()
                    Image(systemName: "arrow.right")
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding()
                .background(Color.blue)
                .cornerRadius(25)
            }
            .disabled(email.isEmpty)
            .padding(.horizontal, 24)
            .padding(.bottom, 8)
            
            Spacer().frame(height: 0)
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            email = authVM.tempUserData.email
        }
    }
}


struct UsernameView: View {
    @EnvironmentObject var authVM: AuthenticationVM
    @State private var username: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            ProgressBar(progress: 2, steps: 3)
            
            ZStack {
                HStack {
                    Button(action: {
                        authVM.onboardingState = .email
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.blue)
                    }
                    Spacer()
                }
                Text("Create Account")
                    .font(.system(size: 17, weight: .semibold))
            }
            .padding(.top, 12)
            .padding(.horizontal, 18)
            
            Spacer().frame(height: 30)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Create a username.")
                    .font(.title)
                    .bold()
                    .padding(.bottom, 20)
                
                TextField("Username", text: $username)
                    .autocapitalization(.none)
                    .autocorrectionDisabled(true)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                    )
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            Button(action: {
                authVM.tempUserData.username = username
                authVM.onboardingState = .password
            }) {
                HStack {
                    Spacer()
                    Text("Next")
                        .foregroundColor(.white)
                        .bold()
                    Image(systemName: "arrow.right")
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding()
                .background(Color.blue)
                .cornerRadius(25)
            }
            .disabled(username.isEmpty)
            .padding(.horizontal, 24)
            .padding(.bottom, 8)
            
            Spacer().frame(height: 0)
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            // Restore username if previously entered
            username = authVM.tempUserData.username
        }
    }
}


struct PasswordView: View {
    @EnvironmentObject var authVM: AuthenticationVM
    let email: String
    let username: String
    
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            ProgressBar(progress: 3, steps: 3)
            
            ZStack {
                HStack {
                    Button(action: {
                        authVM.onboardingState = .username
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.blue)
                    }
                    Spacer()
                }
                Text("Create Account")
                    .font(.system(size: 17, weight: .semibold))
            }
            .padding(.top, 12)
            .padding(.horizontal, 18)
            
            Spacer().frame(height: 30)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Create a password")
                    .font(.title)
                    .bold()
                    .padding(.bottom, 20)
                
                SecureField("Password", text: $password)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                    )
                
                SecureField("Confirm Password", text: $confirmPassword)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                    )
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            Button(action: {
                if password == confirmPassword {
                    authVM.tempUserData.password = password
                    Task {
                        try await authVM.createInitialAccount()
                    }
                }
            }) {
                HStack {
                    Spacer()
                    Text("Create Account")
                        .foregroundColor(.white)
                        .bold()
                    Spacer()
                }
                .padding()
                .background(Color.blue)
                .cornerRadius(25)
            }
            .disabled(password.isEmpty || confirmPassword.isEmpty || password != confirmPassword)
            .padding(.horizontal, 24)
            .padding(.bottom, 8)
            
            Spacer().frame(height: 0)
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            password = authVM.tempUserData.password
        }
    }
}


struct ProgressBar: View {
    var progress: Int
    var steps: Int
    var spacing: CGFloat = 4
    var barFraction: CGFloat = 5 / 8

    var body: some View {
        GeometryReader { geometry in
            let totalWidth = geometry.size.width * barFraction
            let capsuleWidth = max(
                0,
                (totalWidth - spacing * CGFloat(steps - 1)) / CGFloat(steps)
            )
            
            HStack(spacing: spacing) {
                ForEach(0..<steps, id: \.self) { index in
                    Capsule()
                        .fill(index < progress ? Color.blue : Color.gray.opacity(0.3))
                        .frame(width: capsuleWidth, height: 4)
                }
            }
            .frame(width: totalWidth)
            .position(x: geometry.size.width / 2, y: 12)
        }
        .frame(height: 20)
        .padding(.top, 8)
    }
}


#Preview {
    EmailView()
}
