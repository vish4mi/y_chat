//
//  GroupDetailsView.swift
//  Y Chat
//
//  Created by Vishal on 16/03/25.
//

import SwiftUI
import FirebaseAuth

struct GroupDetailsView: View {
    let conversation: Conversation
    
    var body: some View {
        NavigationStack {
            List {
                Section("Members") {
                    ForEach(Array(zip(conversation.participants, conversation.participantNames)), id: \.0) { id, name in
                        Text(name)
                    }
                }
                
                if conversation.admin == Auth.auth().currentUser?.uid {
                    Section("Group Management") {
                        NavigationLink("Add Members") {
                            AddGroupMembersView(conversation: conversation)
                        }
                    }
                }
            }
            .navigationTitle(conversation.groupName ?? "Group Details")
        }
    }
}
