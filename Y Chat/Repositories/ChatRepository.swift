//
//  MessageRepository.swift
//  Y Chat
//
//  Created by Vishal on 17/03/25.
//

import Combine
import Foundation

class ChatRepository {
    private let chatRequest: ChatRequestProtocol
    private let mediaRequest: MediaRequestProtocol
    
    private var cancellables = Set<AnyCancellable>()
    
    init(
        chatRequest: ChatRequestProtocol = FirestoreChatRequest(),
        mediaRequest: MediaRequestProtocol = FirebaseMediaRequest()
    ) {
        self.chatRequest = chatRequest
        self.mediaRequest = mediaRequest
    }
    
    func fetchConversation(conversationId: String) -> AnyPublisher<Conversation?, Error> {
        return chatRequest.fetchConversation(conversationId: conversationId)
    }
    
    func fetchMessages(conversationId: String) -> AnyPublisher<[Message], Error> {
        return chatRequest.fetchMessages(conversationId: conversationId)
    }
    
    func sendDirectMessage(message: Message, conversationId: String) -> AnyPublisher<Void, Error> {
        return chatRequest.sendDirectMessage(message: message, conversationId: conversationId)
    }
    
    func sendGroupMessage(message: Message, conversationId: String) -> AnyPublisher<Void, Error> {
        return chatRequest.sendGroupMessage(message: message, conversationId: conversationId)
    }
    
    func updateLastMessage(message: Message, conversationId: String) -> AnyPublisher<Void, Error> {
        return chatRequest.updateLastMessage(message: message, conversationId: conversationId)
    }
    
    func updateTypingStatus(isTyping: Bool, conversationId: String, currentUserId: String) -> AnyPublisher<Void, Error> {
        return chatRequest.updateTypingStatus(isTyping: isTyping, conversationId: conversationId, currentUserId: currentUserId)
    }
    
    func observeTyping(conversationId: String, currentUserId: String) -> AnyPublisher<[String], Error> {
        return chatRequest.observeTyping(conversationId: conversationId, currentUserId: currentUserId)
    }
    
    func markMessageAsDelivered(messageId: String, conversationId: String) -> AnyPublisher<Void, Error> {
        return chatRequest.markMessageAsDelivered(messageId: messageId, conversationId: conversationId)
    }
    
    func markMessageAsRead(messageId: String, conversationId: String) -> AnyPublisher<Void, Error> {
        return chatRequest.markMessageAsRead(messageId: messageId, conversationId: conversationId)
    }
    
    func sendMediaMessage(mediaURL: String, mediaType: MediaType, conversationId: String, currentUserId: String, senderName: String) -> AnyPublisher<Void, Error> {
        return chatRequest.sendMediaMessage(mediaURL: mediaURL, mediaType: mediaType, conversationId: conversationId, currentUserId: currentUserId, senderName: senderName)
    }
    
    func listenForMessages(conversationId: String) -> AnyPublisher<[Message], Error> {
        return chatRequest.listenForMessages(conversationId: conversationId)
    }
    
    func markAllMessagesAsRead(conversationId: String, currentUserId: String) -> AnyPublisher<Void, Error> {
        return chatRequest.markAllMessagesAsRead(conversationId: conversationId, currentUserId: currentUserId)
    }
    
    func sendMediaMessage(message: Message, conversationId: String) -> AnyPublisher<Void, Error> {
        return chatRequest.sendMediaMessage(message: message, conversationId: conversationId)
    }
    
    func removeListeners() {
        return chatRequest.removeListeners()
    }
    
    func uploadMedia(fileURL: URL, userId: String) -> AnyPublisher<URL, Error> {
        return mediaRequest.uploadMedia(fileURL: fileURL, userId: userId)
    }
    
    func fetchConversations(userId: String) -> AnyPublisher<[Conversation], Error> {
        return chatRequest.fetchConversations(userId: userId)
    }
    
    func listenForLastMessage(conversationId: String) -> AnyPublisher<Message, Error> {
        return chatRequest.listenForLastMessage(conversationId: conversationId)
    }
}
