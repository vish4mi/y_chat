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
    @StateObject var authViewModel: AuthViewModel
    var coreDataStack = CoreDataStack.shared
    let appDependencies: AppDependencies
    
    init() {
        FirebaseApp.configure() // Firebase initialization
        // Create the AppDependencies object
        appDependencies = AppDependencies()
        _authViewModel = StateObject(wrappedValue: AuthViewModel())
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                Group {
                    if authViewModel.isAuthenticated {
                        ConversationsListView(authViewModel: authViewModel)
                    } else {
                        AuthView(viewModel: authViewModel)
                    }
                }
            }
            .environmentObject(appDependencies)
            .navigationViewStyle(.stack)
            .onAppear {
                authViewModel.authRepository = appDependencies.authRepository
                authViewModel.setupAuthListener()
            }
        }
    }
}
