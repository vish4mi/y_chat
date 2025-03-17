//
//  Conversation.swift
//  Y Chat
//
//  Created by Vishal on 15/03/25.
//

import FirebaseFirestoreSwift
import FirebaseAuth
import Foundation

struct Conversation: Identifiable, Codable {
    @DocumentID var id: String?
    let participants: [String]
    let participantNames: [String]
    var lastMessage: String
    var lastMessageSenderId: String
    var lastMessageStatus: MessageStatus? = .sent
    @ServerTimestamp var timestamp: Date?

    // Computed property for UI
    var participantName: String {
        // Implement logic to get other participant's name
        participants.first ?? "Unknown"
    }
    
    // Computed property to get the last message sender's name
    var lastMessageSenderName: String {
        if let index = participants.firstIndex(of: lastMessageSenderId) {
            return participantNames.indices.contains(index) ? participantNames[index] : "Unknown"
        }
        return "Unknown"
    }
    
    // Group chat properties
    var groupName: String?
    var groupIcon: String?
    var isGroup: Bool = false
    var admin: String?
    
    // Computed properties
    var displayName: String {
        if isGroup {
            return groupName ?? participants.prefix(3).joined(separator: ", ")
        }
        return otherParticipantUsername
    }
    
    var otherParticipantUsername: String {
        guard let currentUserId = Auth.auth().currentUser?.uid,
              let index = participants.firstIndex(of: currentUserId)
        else { return "Unknown" }
        
        return participantNames.indices.contains(1 - index) ?
        participantNames[1 - index] :
        participants.first ?? "Unknown"
    }
    
    // MARK: - Initializers
    // For 1:1 chats
    init(participants: [String], participantNames: [String], lastMessage: String, lastMessageSenderId: String = "") {
        self.participants = participants
        self.participantNames = participantNames
        self.lastMessage = lastMessage
        self.isGroup = false
        self.lastMessageSenderId = lastMessageSenderId
    }
    
    // For group chats
    init(groupName: String,
         participants: [String],
         participantNames: [String],
         admin: String,
         lastMessage: String = "",
         lastMessageSenderId: String = ""
    ) {
        self.groupName = groupName
        self.participants = participants
        self.participantNames = participantNames
        self.admin = admin
        self.lastMessage = lastMessage
        self.isGroup = true
        self.lastMessageSenderId = lastMessageSenderId
    }
}
