//
//  NewChatView.swift
//  Y Chat
//
//  Created by Vishal on 15/03/25.
//

import SwiftUI
import FirebaseFirestore

struct NewChatView: View {
    @EnvironmentObject var appDependencies: AppDependencies
    @StateObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    @StateObject var newChatViewModel: NewChatViewModel
    @State private var searchQuery = ""
    
    init(authViewModel: AuthViewModel, isPresented: Binding<Bool>) {
        _authViewModel = StateObject(wrappedValue: authViewModel)
        _newChatViewModel = StateObject(wrappedValue: NewChatViewModel(authViewModel: authViewModel, isPresented: isPresented))
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                TextField("Search by email or phone", text: $searchQuery)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .onChange(of: searchQuery) { newChatViewModel.searchUsers(query: $0) }
                
                if newChatViewModel.isSearching {
                    ProgressView()
                } else if let error = newChatViewModel.error {
                    Text(error)
                        .foregroundColor(.red)
                } else {
                    List(newChatViewModel.searchResults) { user in
                        Button {
                            newChatViewModel.startChat(with: user)
                        } label: {
                            Text(user.email)
                        }
                    }
                }
                
                Spacer()
            }
            .navigationTitle("New Chat")
            .toolbar {
                Button("Cancel") { dismiss() }
            }
        }
    }
}
