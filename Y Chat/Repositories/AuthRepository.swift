//
//  AuthRepository.swift
//  Y Chat
//
//  Created by Vishal on 17/03/25.
//

import Combine
import Foundation

class AuthRepository {    
    private var cancellables = Set<AnyCancellable>()
    private let authRequest: AuthRequestProtocol
    private let firestoreRequest: FirebaseFirestoreRequest
    
    init(
        authRequest: AuthRequestProtocol = FirebaseAuthRequest(),
        firestoreRequest: FirebaseFirestoreRequest = FirebaseFirestoreRequest()
    ) {
        self.authRequest = authRequest
        self.firestoreRequest = firestoreRequest
    }
    
    func signIn(email: String, password: String) -> AnyPublisher<ChatUser, Error> {
        return authRequest.signIn(email: email, password: password)
    }
    
    func signUp(email: String, password: String, username: String) -> AnyPublisher<ChatUser, Error> {
        return authRequest.signUp(email: email, password: password)
            .flatMap { [weak self] authResult -> AnyPublisher<ChatUser, Error> in
                guard let self = self else {
                    return Fail(error: NSError(domain: "AuthError", code: -1, userInfo: nil)).eraseToAnyPublisher()
                }
                
                return self.authRequest.updateUserProfile(displayName: username)
                    .flatMap { _ -> AnyPublisher<ChatUser, Error> in
                        let user = ChatUser(
                            email: email.lowercased(),
                            uid: authResult.uid,
                            username: username
                        )
                        return self.firestoreRequest.saveUserData(user: user)
                            .map { _ -> ChatUser in
                                return user // Return the ChatUser after saving data
                            }
                            .eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func signOut() -> AnyPublisher<Bool, Error> {
        return authRequest.signOut()
    }
    
    func authStateListener() -> AnyPublisher<ChatUser, Never> {
        return authRequest.authStateListener()
    }
}
