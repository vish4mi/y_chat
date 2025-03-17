//
//  ConversationsViewModel.swift
//  Y Chat
//
//  Created by Vishal on 15/03/25.
//

import FirebaseFirestore
import FirebaseAuth

class ConversationsViewModel: ObservableObject {
    @Published var conversations: [Conversation] = []
    private var listener: ListenerRegistration?
    // Track message listeners for each conversation
    private var messageListeners: [String: ListenerRegistration] = [:]

    // In ConversationsViewModel.swift
    func fetchConversations() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        listener = Firestore.firestore()
            .collection("conversations")
            .whereField("participants", arrayContains: userId)
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    print("Conversations listener error: \(error)")
                    return
                }
                
                guard let docs = snapshot?.documents else {
                    print("No conversation documents found")
                    return
                }
                
                print("📥 Fetched \(docs.count) conversations")
                self?.conversations = docs.compactMap { doc in
                    do {
                        let conversation = try doc.data(as: Conversation.self)
                        print("Conversation: \(conversation.lastMessage )")
                        self?.listenForMessages(conversationId: conversation.id ?? "")
                        return conversation
                    } catch {
                        print("Decoding error: \(error)")
                        return nil
                    }
                }
            }
    }
    
    // Listen for new messages in a specific conversation
    func listenForMessages(conversationId: String) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        // Remove existing listener if any
        messageListeners[conversationId]?.remove()
        
        // Add new listener
        messageListeners[conversationId] = Firestore.firestore()
            .collection("conversations")
            .document(conversationId)
            .collection("messages")
            .order(by: "timestamp", descending: true)
            .limit(to: 1) // Only listen to the latest message
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    print("Messages listener error: \(error)")
                    return
                }
                
                guard let docs = snapshot?.documents, let latestMessageDoc = docs.first else {
                    print("No messages found")
                    return
                }
                
                if let latestMessage = try? latestMessageDoc.data(as: Message.self) {
                    // Update the conversation's last message and sender
                    self?.updateConversationLastMessage(
                        conversationId: conversationId,
                        lastMessage: latestMessage.text,
                        lastMessageSenderId: latestMessage.senderId
                    )
                    
                    // Mark the message as delivered if it was sent by someone else
                    if latestMessage.senderId != currentUserId && latestMessage.status == .sent {
                        self?.markMessageAsDelivered(
                            messageId: latestMessageDoc.documentID,
                            conversationId: conversationId
                        )
                    }
                }
            }
    }
        
    // Update the conversation's last message and sender
    private func updateConversationLastMessage(conversationId: String, lastMessage: String, lastMessageSenderId: String) {
        if let index = conversations.firstIndex(where: { $0.id == conversationId }) {
            conversations[index].lastMessage = lastMessage
            conversations[index].lastMessageSenderId = lastMessageSenderId
        }
    }
    
    // Mark a message as delivered
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
}
