//
//  FirebaseAuthRequest.swift
//  Y Chat
//
//  Created by Vishal on 17/03/25.
//

import FirebaseAuth
import Combine


// Implement the request layer using Firebase
class FirebaseAuthRequest: AuthRequestProtocol {
    
    private let authStateSubject = PassthroughSubject<ChatUser, Never>()

    init() {
        // Set up the Firebase authentication state listener
        Auth.auth().addStateDidChangeListener { [weak self] (_, user) in
            let chatUser = ChatUser(
                email: user?.email ?? "",
                uid: user?.uid ?? "",
                username: user?.displayName ?? "Unknown"
            )
            self?.authStateSubject.send(chatUser)
        }
    }
    
    func signIn(email: String, password: String) -> AnyPublisher<ChatUser, Error> {
        return Future<ChatUser, Error> { promise in
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                if let error = error {
                    promise(.failure(error))
                } else if let user = result?.user {
                    // Fetch additional user details (e.g., username) from Firestore or another source
                    let chatUser = ChatUser(
                        email: user.email ?? email, // Use the provided email as a fallback
                        uid: user.uid,
                        username: user.displayName ?? "Unknown" // Use a default or fetch from Firestore
                    )
                    promise(.success(chatUser))
                } else {
                    promise(.failure(NSError(
                        domain: "AuthError",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Unexpected error occurred"]
                    )))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    
    func signUp(email: String, password: String) -> AnyPublisher<ChatUser, Error> {
        return Future { promise in
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                if let error = error {
                    promise(.failure(error))
                } else if let result = result {
                    let chatUser = ChatUser(
                        email: result.user.email ?? "",
                        uid: result.user.uid,
                        username: result.user.displayName ?? ""
                    )
                    promise(.success(chatUser))
                } else {
                    // Handle the case where both result and error are nil
                    promise(.failure(NSError(
                        domain: "AuthError",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Unknown error occurred"]
                    )))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func updateUserProfile(displayName: String) -> AnyPublisher<Void, Error> {
        return Future { promise in
            guard let user = Auth.auth().currentUser else {
                promise(.failure(NSError(domain: "AuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "No authenticated user"])))
                return
            }
            
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = displayName
            changeRequest.commitChanges { error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func signOut() -> AnyPublisher<Bool, Error> {
        return Future { promise in
            do {
                try Auth.auth().signOut()
                promise(.success(true))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func authStateListener() -> AnyPublisher<ChatUser, Never> {
        return authStateSubject.eraseToAnyPublisher()
    }
}
