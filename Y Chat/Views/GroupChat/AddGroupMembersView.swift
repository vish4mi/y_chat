//
//  AddGroupMembersView.swift
//  Y Chat
//
//  Created by Vishal on 16/03/25.
//

import SwiftUI

struct AddGroupMembersView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject var vm = AddGroupMembersViewModel()
    let conversation: Conversation
    @State private var searchText = ""
    
    var filteredUsers: [ChatUser] {
        if searchText.isEmpty {
            return vm.availableUsers
        }
        return vm.availableUsers.filter {
            $0.username.localizedCaseInsensitiveContains(searchText) ||
            $0.email.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        List {
            Section("Search Users") {
                TextField("Name or email", text: $searchText)
                    .autocapitalization(.none)
            }
            
            Section("Available Users") {
                ForEach(filteredUsers) { user in
                    HStack {
                        Text(user.username)
                        Spacer()
                        if vm.selectedUsers.contains(user) {
                            Image(systemName: "checkmark")
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if vm.selectedUsers.contains(user) {
                            vm.selectedUsers.removeAll { $0.id == user.id }
                        } else {
                            vm.selectedUsers.append(user)
                        }
                    }
                }
            }
            
            Section {
                Button("Add Selected Members") {
                    vm.addMembersToGroup(conversation: conversation)
                }
                .disabled(vm.selectedUsers.isEmpty)
            }
        }
        .navigationTitle("Add Members")
        .onAppear {
            vm.fetchAvailableUsers(currentParticipants: conversation.participants)
        }
    }
}
