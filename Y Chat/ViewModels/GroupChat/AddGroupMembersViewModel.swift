//
//  AddGroupMembersViewModel.swift
//  Y Chat
//
//  Created by Vishal on 16/03/25.
//

import Foundation
import FirebaseFirestore

class AddGroupMembersViewModel: ObservableObject {
    @Published var availableUsers: [ChatUser] = []
    @Published var selectedUsers: [ChatUser] = []
    
    func fetchAvailableUsers(currentParticipants: [String]) {
        Firestore.firestore()
            .collection("users")
            .whereField("id", notIn: currentParticipants)
            .getDocuments { [weak self] snapshot, _ in
                self?.availableUsers = snapshot?.documents.compactMap {
                    try? $0.data(as: ChatUser.self)
                } ?? []
            }
    }
    
    func addMembersToGroup(conversation: Conversation) {
        let newParticipants = selectedUsers.map { $0.id }
        let newParticipantNames = selectedUsers.map { $0.username }
        
        let updates: [String: Any] = [
            "participants": FieldValue.arrayUnion(newParticipants as [Any]),
            "participantNames": FieldValue.arrayUnion(newParticipantNames)
        ]
        
        Firestore.firestore()
            .collection("conversations")
            .document(conversation.id ?? "")
            .updateData(updates) { error in
                if let error = error {
                    print("Error adding members: \(error.localizedDescription)")
                } else {
                    print("Successfully added \(newParticipants.count) members")
                }
            }
    }
}
