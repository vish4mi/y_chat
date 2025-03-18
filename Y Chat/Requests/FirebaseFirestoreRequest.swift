//
//  FirebaseFirestoreRequest.swift
//  Y Chat
//
//  Created by Vishal on 17/03/25.
//

import Combine
import FirebaseFirestore

class FirebaseFirestoreRequest: FirestoreRequestProtocol {
    
    func saveUserData(user: ChatUser) -> AnyPublisher<Void, Error> {
        return Future { promise in
            do {
                try Firestore.firestore()
                    .collection("users")
                    .document(user.uid)
                    .setData(from: user)
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
}
