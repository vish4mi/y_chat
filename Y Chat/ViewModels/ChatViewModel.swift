//
//  ChatViewModel.swift
//  Y Chat
//
//  Created by Vishal on 12/03/25.
//

import FirebaseFirestore
import FirebaseAuth
import Combine
import SwiftUI

class ChatViewModel: ObservableObject {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Published var messages: [Message] = []
    var currentUserId: String
    private var listener: ListenerRegistration?
    private let conversationId: String
    @Published var isTyping = false // 👈 Add this
    @Published var isGroupChat = false
    @Published var typingUserNames: [String] = []
    @Published var conversation: Conversation?
    
    init(conversationId: String, currentUserId: String) {
        self.conversationId = conversationId
        self.currentUserId = currentUserId
        self.fetchConversation()
    }
    
    func fetchConversation() {
        Firestore.firestore()
            .collection("conversations")
            .document(conversationId)
            .addSnapshotListener { [weak self] snapshot, _ in
                self?.conversation = try? snapshot?.data(as: Conversation.self)
            }
    }
    
    func fetchMessages(conversationId: String) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        listener = Firestore.firestore()
            .collection("conversations")
            .document(conversationId)
            .collection("messages")
            .order(by: "timestamp")
            .addSnapshotListener { [weak self] snapshot, _ in
                guard let documents = snapshot?.documents else { return }
                
                var updatedMessages: [Message] = []
                
                for document in documents {
                    if var message = try? document.data(as: Message.self) {
                        // Mark as delivered if the message is sent by someone else
                        if message.senderId != currentUserId && message.status == .sent {
                            self?.markMessageAsDelivered(messageId: document.documentID, conversationId: conversationId)
                            message.status = .delivered
                        }
                        if message.senderId != currentUserId && message.status == .delivered {
                            self?.markAllMessagesAsRead(conversationId: conversationId)
                            message.status = .read
                        }
                        
                        updatedMessages.append(message)
                    }
                }
                
                self?.messages = updatedMessages
            }
    }
    
    func sendMessage(_ text: String) {
        if conversation?.isGroup == true {
            sendGroupMessage(text)
        } else {
            sendDirectMessage(text)
        }
    }

    private func sendDirectMessage(_ text: String) {
        let message = Message(
            text: text,
            senderId: currentUserId,
            senderName: getSenderName(),
            timestamp: Date()
        )
        
        do {
            try Firestore.firestore()
                .collection("conversations")
                .document(conversationId)
                .collection("messages")
                .document(message.id)
                .setData(from: message)
            
            messages.append(message)
            messages.sort {
                $0.timestamp! < $1.timestamp!
            }
            updateLastDirectMessage(message: message)
        } catch {
            print("Error sending message: \(error)")
        }
    }
    
    func sendGroupMessage(_ text: String) {        
        let message = Message(
            text: text,
            senderId: currentUserId,
            senderName: getSenderName(),  // Implement this
            groupId: conversationId
        )
        
        do {
            try Firestore.firestore()
                .collection("conversations")
                .document(conversationId)
                .collection("messages")
                .document(message.id)
                .setData(from: message)
            
            messages.append(message)
            messages.sort { ($0.timestamp ?? Date.distantFuture) > ($1.timestamp ?? Date.distantFuture) }

            // Update conversation last message
            updateLastGroupMessage(message: message)
        } catch {
            print("Error sending group message: \(error)")
        }
    }
    
    private func getSenderName() -> String {
        Auth.auth().currentUser?.displayName ?? "Unknown User"
    }
    
    private func updateLastGroupMessage(message: Message) {
        Firestore.firestore()
            .collection("conversations")
            .document(conversationId)
            .updateData([
                "lastMessage": message.text,
                "lastMessageSenderId": message.senderId,
                "lastMessageSenderName": message.senderName,
                "timestamp": FieldValue.serverTimestamp()
            ])
    }
    
    func updateTypingStatus(isTyping: Bool, conversationId: String) {
        Firestore.firestore()
            .collection("conversations")
            .document(conversationId)
            .updateData(["isTyping.\(currentUserId)": isTyping])
    }
    
    func removeListeners() {
        listener?.remove()
    }
    
    func handleTyping(isTyping: Bool) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        let typingRef = Firestore.firestore()
            .collection("conversations")
            .document(conversationId)
            .collection("typing")
            .document(currentUserId)
        
        if isTyping {
            typingRef.setData([
                "isTyping": true,
                "timestamp": FieldValue.serverTimestamp(),
                "userId": currentUserId
            ])
        } else {
            typingRef.delete()
        }
    }

    // In ChatViewModel
    func observeTyping() {
        Firestore.firestore()
            .collection("conversations")
            .document(conversationId)
            .collection("typing")
            .addSnapshotListener { [weak self] snapshot, _ in
                guard let self else { return }
                
                let typingUsers = snapshot?.documents
                    .compactMap { [weak self] doc -> String? in
                        guard doc["isTyping"] as? Bool == true,
                              let userId = doc["userId"] as? String,
                              userId != self?.currentUserId
                        else { return nil }
                        return userId
                    } ?? []
                
                self.typingUserNames = self.conversation?.participantNames
                    .filter { name in
                        typingUsers.contains { userId in
                            self.conversation?.participants.firstIndex(of: userId) ==
                            self.conversation?.participantNames.firstIndex(of: name)
                        }
                    } ?? []
                
                self.isTyping = !typingUsers.isEmpty
            }
    }

    private func updateTypingIndicator(typingUsers: [String]) {
        if !typingUsers.isEmpty {
            // For 1:1 chat
            if !isGroupChat {
                isTyping = true
            }
            // For group chat
            else {
                typingUserNames = typingUsers
            }
        } else {
            isTyping = false
            typingUserNames.removeAll()
        }
    }
    
    private func updateLastDirectMessage(message: Message) {
        let updateData: [String: Any] = [
            "lastMessage": message.text,
            "lastMessageSenderId": message.senderId,
            "lastMessageSenderName": message.senderName,
            "timestamp": FieldValue.serverTimestamp()
        ]
        
        Firestore.firestore()
            .collection("conversations")
            .document(conversationId)
            .updateData(updateData) { error in
                if let error = error {
                    print("Error updating last message: \(error.localizedDescription)")
                } else {
                    print("Last message updated successfully")
                }
            }
    }
    
    func listenForMessages() {
        listener = Firestore.firestore()
            .collection("conversations")
            .document(conversationId)
            .collection("messages")
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error listening for messages: \(error.localizedDescription)")
                    return
                }
                
                guard let docs = snapshot?.documents else { return }
                self.messages = docs.compactMap { doc in
                    try? doc.data(as: Message.self)
                }
            }
    }
    
    func markMessageAsDelivered(messageId: String, conversationId: String) {
        let messageRef = Firestore.firestore()
            .collection("conversations")
            .document(conversationId)
            .collection("messages")
            .document(messageId)
        
        messageRef.updateData(["status": "delivered"]) { error in
            if let error = error {
                print("Error updating message status: \(error.localizedDescription)")
            } else {
                print("Message marked as delivered!")
            }
        }
    }
    
    func markAllMessagesAsRead(conversationId: String) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        for message in messages {
            // Mark as read if:
            // 1. The message was sent by someone else.
            // 2. The message status is "delivered".
            if message.senderId != currentUserId && (message.status == .delivered || message.status == .sent) {
                markMessageAsRead(messageId: message.id, conversationId: conversationId)
            }
        }
    }
    
    func markMessageAsRead(messageId: String, conversationId: String) {
        let messageRef = Firestore.firestore()
            .collection("conversations")
            .document(conversationId)
            .collection("messages")
            .document(messageId)
        
        messageRef.updateData(["status": "read"]) { error in
            if let error = error {
                print("Error updating message status: \(error.localizedDescription)")
            } else {
                print("Message marked as read!")
            }
        }
    }
}
