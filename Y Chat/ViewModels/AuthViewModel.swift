//
//  AuthViewModel.swift
//  Y Chat
//
//  Created by Vishal on 12/03/25.
//

import FirebaseAuth
import FirebaseFirestore
import Combine

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var currentUserId: String?
    @Published var currentUser: ChatUser?

    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupAuthListener()
    }
    
    private func setupAuthListener() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.isAuthenticated = user != nil
            self?.currentUserId = user?.uid // Update current user ID
        }
    }
    
    func login(email: String, password: String) {
        isLoading = true
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] _, error in
            self?.isLoading = false
            if let error = error {
                self?.errorMessage = error.localizedDescription
                self?.showError = true
            }
        }
    }
    
    func signUp(email: String, password: String, username: String) {
        isLoading = true
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            self?.isLoading = false
            
            if let error = error {
                self?.errorMessage = error.localizedDescription
                self?.showError = true
                return
            }
            
            guard let user = result?.user else { return }
            
            // Update the user's profile with the display name
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = username
            changeRequest.commitChanges { error in
                if let error = error {
                    print("Error updating profile: \(error.localizedDescription)")
                } else {
                    print("Display name set successfully!")
                }
            }
            
            let userData = ChatUser(
                email: email.lowercased(),
                uid: user.uid,
                username: username
            )
            // Save to Firestore with error handling
            do {
                try Firestore.firestore()
                    .collection("users")
                    .document(user.uid)
                    .setData(from: userData)
            } catch let encodeError {
                self?.errorMessage = "Failed to save user: \(encodeError.localizedDescription)"
                self?.showError = true
            }
            do {
                try Firestore.firestore()
                    .collection("users") // Ensure collection name matches
                    .document(user.uid)
                    .setData(from: userData)
                print("✅ User saved to Firestore!")
            } catch let encodeError {
                print("❌ Firestore save error: \(String(describing: error?.localizedDescription))")
                self?.errorMessage = "Failed to save user: \(encodeError.localizedDescription)"
                self?.showError = true
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            currentUserId = nil // Clear on sign out
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}
