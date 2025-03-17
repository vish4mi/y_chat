//
//  ChatApp.swift
//  Y Chat
//
//  Created by Vishal on 12/03/25.
//

import SwiftUI
import Firebase

@main
struct ChatApp: App {
    @StateObject var authViewModel = AuthViewModel()
    var coreDataStack = CoreDataStack.shared
    
    init() {
        FirebaseApp.configure() // Firebase initialization
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                Group {
                    if authViewModel.isAuthenticated {
                        ConversationsListView()
                    } else {
                        AuthView()
                    }
                }
                .environment(\.managedObjectContext, coreDataStack.context)
            }
            .environmentObject(authViewModel)
            .navigationViewStyle(.stack)
        }
    }
}
