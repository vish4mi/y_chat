//
//  ConversationRow.swift
//  Y Chat
//
//  Created by Vishal on 15/03/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct ConversationRow: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    let conversation: Conversation
    @State private var participantName = "Loading..."
    
    var body: some View {
        HStack {
            // Group chat icon or profile picture
            if conversation.isGroup {
                Image(systemName: "person.3.fill")
                    .foregroundColor(.blue)
                    .padding(.trailing, 8)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                // Display group name or participant name
                Text(conversation.displayName)
                    .font(.headline)
                
                // Display last message and sender
                HStack {
                    if conversation.isGroup {
                        Text("\(conversation.lastMessageSenderName): \(conversation.lastMessage)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    } else {
                        Text(conversation.lastMessage)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
            
            Spacer()
            
            // Message status and timestamp
//            MessageStatusView(status: conversation.lastMessageStatus ?? .sent)
            Text(conversation.timestamp?.formatted(date: .omitted, time: .shortened) ?? "Unknown Time")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 8)
    }
    
    private func fetchParticipantName() {
        // 1. Check for valid current user
        guard let currentUserId = authViewModel.currentUserId else {
            participantName = "Unknown User"
            return
        }
        
        // 2. Safely get other participant ID
        let otherParticipants = conversation.participants.filter { $0 != currentUserId }
        guard !otherParticipants.isEmpty else {
            participantName = "Self Conversation"
            return
        }
        
        // 3. Handle group chats differently if needed
        if conversation.isGroup {
            participantName = conversation.groupName ?? "Group Chat"
            return
        }
        
        // 4. Get first valid individual participant
        let otherUserId = otherParticipants[0]
        guard !otherUserId.isEmpty else {
            participantName = "Unknown User"
            return
        }
        
        // 5. Fetch user data safely
        Firestore.firestore()
            .collection("users")
            .document(otherUserId)
            .getDocument { snapshot, _ in
                if let name = snapshot?.get("username") as? String {
                    self.participantName = name
                } else {
                    self.participantName = "Unknown User"
                }
            }
    }
}
