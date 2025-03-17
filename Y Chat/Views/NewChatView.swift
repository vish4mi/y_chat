//
//  NewChatView.swift
//  Y Chat
//
//  Created by Vishal on 15/03/25.
//

import SwiftUI
import FirebaseFirestore

struct NewChatView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.dismiss) var dismiss
    @StateObject var vm = NewChatViewModel()
    @State private var searchQuery = ""
    
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
                    .onChange(of: searchQuery) { vm.searchUsers(query: $0) }
                
                if vm.isSearching {
                    ProgressView()
                } else if let error = vm.error {
                    Text(error)
                        .foregroundColor(.red)
                } else {
                    List(vm.searchResults) { user in
                        Button {
                            vm.startChat(with: user)
                            dismiss()
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
