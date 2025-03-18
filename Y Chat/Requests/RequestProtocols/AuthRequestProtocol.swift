//
//  AuthRequestProtocol.swift
//  Y Chat
//
//  Created by Vishal on 17/03/25.
//

import Combine

// Define a protocol for the request layer
protocol AuthRequestProtocol {
    func signIn(email: String, password: String) -> AnyPublisher<ChatUser, Error>
    func signUp(email: String, password: String) -> AnyPublisher<ChatUser, Error>
    func updateUserProfile(displayName: String) -> AnyPublisher<Void, Error>
    func signOut() -> AnyPublisher<Bool, Error>
    func authStateListener() -> AnyPublisher<ChatUser, Never>
}
