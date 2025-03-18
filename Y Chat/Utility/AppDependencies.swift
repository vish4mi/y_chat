//
//  AppDependencies.swift
//  Y Chat
//
//  Created by Vishal on 17/03/25.
//

import Combine
import Foundation

class AppDependencies: ObservableObject {
    let chatRepository: ChatRepository
    let authRepository: AuthRepository
    
    init(coreDataStack: CoreDataStack) {
        // Create instances of services and repositories
        self.chatRepository = ChatRepository(chatRequest: FirestoreChatRequest(), persistentContainer: coreDataStack.persistentContainer)
        self.authRepository = AuthRepository(authRequest: FirebaseAuthRequest())
    }
}
