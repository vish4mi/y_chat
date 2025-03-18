//
//  ChatRequestProtocol.swift
//  Y Chat
//
//  Created by Vishal on 18/03/25.
//

import Combine
import FirebaseFirestore

protocol ChatRequestProtocol {
    func fetchConversation(conversationId: String) -> AnyPublisher<Conversation?, Error>
    func fetchMessages(conversationId: String) -> AnyPublisher<[Message], Error>
    func sendDirectMessage(message: Message, conversationId: String) -> AnyPublisher<Void, Error>
    func sendGroupMessage(message: Message, conversationId: String) -> AnyPublisher<Void, Error>
    func updateLastMessage(message: Message, conversationId: String) -> AnyPublisher<Void, Error>
    func updateTypingStatus(isTyping: Bool, conversationId: String, currentUserId: String) -> AnyPublisher<Void, Error>
    func observeTyping(conversationId: String, currentUserId: String) -> AnyPublisher<[String], Error>
    func markMessageAsDelivered(messageId: String, conversationId: String) -> AnyPublisher<Void, Error>
    func markMessageAsRead(messageId: String, conversationId: String) -> AnyPublisher<Void, Error>
    func markAllMessagesAsRead(conversationId: String, currentUserId: String) -> AnyPublisher<Void, Error>
    func sendMediaMessage(mediaURL: String, mediaType: MediaType, conversationId: String, currentUserId: String, senderName: String) -> AnyPublisher<Void, Error>
    func removeListeners()
    func listenForMessages(conversationId: String) -> AnyPublisher<[Message], Error>
    func sendMediaMessage(message: Message, conversationId: String) -> AnyPublisher<Void, Error>
    
    func fetchConversations(userId: String) -> AnyPublisher<[Conversation], Error>
    func listenForLastMessage(conversationId: String) -> AnyPublisher<Message, Error>
}
