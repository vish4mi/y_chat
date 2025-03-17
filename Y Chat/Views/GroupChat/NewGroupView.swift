//
//  NewGroupView.swift
//  Y Chat
//
//  Created by Vishal on 16/03/25.
//

import SwiftUI

struct NewGroupView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.dismiss) var dismiss
    @StateObject var vm = NewGroupViewModel()
    @State private var groupName = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                TextField("Group Name", text: $groupName)
                    .padding()
                
                List {
                    ForEach(vm.users) { user in
                        MultipleSelectionRow(
                            user: user,
                            isSelected: vm.selectedUsers.contains(user)
                        ) {
                            if vm.selectedUsers.contains(user) {
                                vm.selectedUsers.removeAll { $0.id == user.id }
                            } else {
                                vm.selectedUsers.append(user)
                            }
                        }
                    }
                }
                
                Button("Create Group") {
                    vm.createGroup(name: groupName)
                    dismiss()
                }
                .disabled(groupName.isEmpty || vm.selectedUsers.count < 2)
            }
            .navigationTitle("New Group")
            .onAppear { vm.fetchUsers() }
        }
    }
}

struct MultipleSelectionRow: View {
    let user: ChatUser
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(user.username)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                }
            }
        }
    }
}
