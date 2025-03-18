//
//  AuthView.swift
//  Y Chat
//
//  Created by Vishal on 12/03/25.
//

import SwiftUI

struct AuthView: View {
    @StateObject private var viewModel: AuthViewModel
    
    init(viewModel: AuthViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var username: String = ""
    @State private var isLoginMode = true

    var body: some View {
        VStack(spacing: 20) {
            Picker("Auth Mode", selection: $isLoginMode) {
                Text("Login").tag(true)
                Text("Sign Up").tag(false)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            if !isLoginMode {
                TextField("Username", text: $username)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
            
            TextField("Email", text: $email)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
            
            SecureField("Password", text: $password)
                .textContentType(.password)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
            
            Button(action: handleAuth) {
                Text(isLoginMode ? "Login" : "Sign Up")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            
            if viewModel.isLoading {
                ProgressView()
            }
        }
        .padding()
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage)
        }
    }
    
    private func handleAuth() {
        if isLoginMode {
            viewModel.login(email: email, password: password)
        } else {
            viewModel.signUp(email: email, password: password, username: username)
        }
    }
}
