//
//  ConversationsViewModel.swift
//  Y Chat
//
//  Created by Vishal on 15/03/25.
//

import FirebaseFirestore
import FirebaseAuth
import Combine

class ConversationsViewModel: ObservableObject {
    @Published var conversations: [Conversation] = []
    
    private var listener: ListenerRegistration?
    private var messageListeners: [String: ListenerRegistration] = [:]
    private var cancellables = Set<AnyCancellable>()

    var chatRepository: ChatRepository?

    func fetchConversations() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        chatRepository?.fetchConversations(userId: userId)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(_):
                    break
                case .finished:
                    break
                }
            } receiveValue: { [weak self] conversations in
                self?.conversations = conversations
                conversations.forEach { conversation in
                    if let conversationId = conversation.id {
                        self?.listenForMessages(conversationId: conversationId)
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    func listenForMessages(conversationId: String) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        chatRepository?.listenForLastMessage(conversationId: conversationId)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(_):
                    break
                case .finished:
                    break
                }
            } receiveValue: { [weak self] message in
                self?.updateConversationLastMessage(
                    conversationId: conversationId,
                    lastMessage: message.text,
                    lastMessageSenderId: message.senderId
                )
                
                if message.senderId != currentUserId && message.status == .sent {
                    self?.markMessageAsDelivered(
                        messageId: message.id,
                        conversationId: conversationId
                    )
                }
            }
            .store(in: &cancellables)
    }
    
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
