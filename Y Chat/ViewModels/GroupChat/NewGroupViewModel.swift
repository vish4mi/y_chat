//
//  NewGroupViewModel.swift
//  Y Chat
//
//  Created by Vishal on 16/03/25.
//

import FirebaseAuth
import FirebaseFirestore

class NewGroupViewModel: ObservableObject {
    @Published var users: [ChatUser] = []
    @Published var selectedUsers: [ChatUser] = []
    
    func fetchUsers() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        Firestore.firestore()
            .collection("users")
            .whereField("uid", isNotEqualTo: currentUserId)
            .getDocuments { [weak self] snapshot, _ in
                self?.users = snapshot?.documents.compactMap {
                    try? $0.data(as: ChatUser.self)
                } ?? []
            }
    }
    
    func createGroup(name: String) {
        guard let currentUserId = Auth.auth().currentUser?.uid,
              let currentUserName = Auth.auth().currentUser?.displayName
        else {
            print("Error: Current user not authenticated")
            return
        }
        
        // Safely unwrap and filter out nil IDs
        let selectedUserIDs = selectedUsers.compactMap { $0.id }
        
        // Combine with current user's ID
        let allParticipants = selectedUserIDs + [currentUserId]
        
        // Get names (also handle optional usernames)
        let allParticipantNames = selectedUsers.compactMap { $0.username } + [currentUserName]
        
        // Ensure we have at least 2 participants (current user + at least 1 other)
        guard allParticipants.count >= 2 else {
            print("Error: Need at least 1 other participant to create group")
            return
        }
        
        let group = Conversation(
            groupName: name,
            participants: allParticipants,
            participantNames: allParticipantNames,
            admin: currentUserId
        )
        
        do {
            try Firestore.firestore()
                .collection("conversations")
                .document()
                .setData(from: group)
            print("Group created successfully!")
        } catch {
            print("Error creating group: \(error.localizedDescription)")
        }
    }
}
