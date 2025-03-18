//
//  FirestoreRequestProtocol.swift
//  Y Chat
//
//  Created by Vishal on 18/03/25.
//

import Combine
import FirebaseFirestore

protocol FirestoreRequestProtocol {
    func saveUserData(user: ChatUser) -> AnyPublisher<Void, Error>
}
