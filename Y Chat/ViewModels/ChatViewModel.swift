//
//  ChatViewModel.swift
//  Y Chat
//
//  Created by Vishal on 12/03/25.
//

import Combine
import SwiftUI
import FirebaseStorage

class ChatViewModel: ObservableObject {
    @StateObject var authViewModel: AuthViewModel
    @Published var messages: [Message] = []
    var currentUserId: String
    private let conversationId: String
    @Published var isTyping = false
    @Published var isGroupChat = false
    @Published var typingUserNames: [String] = []
    @Published var conversation: Conversation?
    
    var chatRepository: ChatRepository?
    private var cancellables = Set<AnyCancellable>()

    init(conversationId: String, currentUserId: String, authViewModel: AuthViewModel) {
        _authViewModel = StateObject(wrappedValue: authViewModel)
        self.conversationId = conversationId
        self.currentUserId = currentUserId
    }
    
    func fetchConversation() {
        chatRepository?.fetchConversation(conversationId: conversationId)
            .sink { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    print("Error fetching conversation: \(error.localizedDescription)")
                }
            } receiveValue: { [weak self] conversation in
                self?.conversation = conversation
            }
            .store(in: &cancellables)
    }
    
    func fetchMessages() {
        chatRepository?.fetchMessages(conversationId: conversationId)
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                case .failure(_): break
                case .finished: break
                }
            } receiveValue: { [weak self] messages in
                guard let self = self else { return }
                
                // Update message statuses
                let updatedMessages = messages.map { message in
                    var updatedMessage = message
                    if message.senderId != self.currentUserId {
                        if message.status == .delivered || message.status == .sent {
                            self.markMessageAsRead(messageId: message.id, conversationId: self.conversationId)
                            updatedMessage.status = .read
                        }
                    }
                    return updatedMessage
                }
                
                self.messages = updatedMessages
            }
            .store(in: &cancellables)
    }

    
    func sendMessage(_ text: String) {
        if conversation?.isGroup == true {
            sendGroupMessage(text, conversationId: conversationId)
        } else {
            sendDirectMessage(text, conversationId: conversationId)
        }
    }
    
    func sendDirectMessage(_ text: String, conversationId: String) {
        guard let chatRepository = chatRepository else {
            print("Chat repository is missing.")
            return
        }
        
        let message = Message(
            text: text,
            senderId: currentUserId,
            senderName: getSenderName(),
            timestamp: Date(),
            mediaURL: nil,
            mediaType: nil
        )
        
        chatRepository.sendDirectMessage(message: message, conversationId: conversationId)
            .flatMap { _ -> AnyPublisher<Void, Error> in
                return chatRepository.updateLastMessage(message: message, conversationId: conversationId)
            }
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                case .failure(_): break
                case .finished: break
                }
            } receiveValue: { [weak self] _ in
                self?.messages.append(message)
                self?.messages.sort { $0.timestamp ?? Date.distantFuture < $1.timestamp ?? Date.distantFuture }
            }
            .store(in: &cancellables)
    }
    
    func sendGroupMessage(_ text: String, conversationId: String) {
        guard let chatRepository = chatRepository else {
            print("Chat repository is missing.")
            return
        }
        
        let message = Message(
            text: text,
            senderId: currentUserId,
            senderName: getSenderName(),
            groupId: conversationId,
            mediaURL: nil,
            mediaType: nil
        )
                
        chatRepository.sendGroupMessage(message: message, conversationId: conversationId)
            .flatMap { _ -> AnyPublisher<Void, Error> in
                return chatRepository.updateLastMessage(message: message, conversationId: conversationId)
            }
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                case .failure(_): break
                case .finished: break
                }
            } receiveValue: { [weak self] _ in
                self?.messages.append(message)
                self?.messages.sort { ($0.timestamp ?? Date.distantFuture) > ($1.timestamp ?? Date.distantFuture) }
            }
            .store(in: &cancellables)
    }
    
    private func getSenderName() -> String {
        authViewModel.currentUser?.username ?? "Unknown User"
    }
    
    func updateTypingStatus(isTyping: Bool, conversationId: String) {
        chatRepository?.updateTypingStatus(isTyping: isTyping, conversationId: conversationId, currentUserId: currentUserId)
            .sink { completion in
                switch completion {
                case .failure(_):
                    break
                case .finished:
                    break
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }
    
    func handleTyping(isTyping: Bool, conversationId: String) {
        chatRepository?.updateTypingStatus(isTyping: isTyping, conversationId: conversationId, currentUserId: currentUserId)
            .sink { completion in
                switch completion {
                case .failure(_):
                    break
                case .finished:
                    break
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }
    
    func observeTyping() {
        chatRepository?.observeTyping(conversationId: conversationId, currentUserId: currentUserId)
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                case .failure(_):
                    break
                case .finished:
                    break
                }
            } receiveValue: { [weak self] typingUsers in
                guard let self = self else { return }
                
                // Map typing user IDs to names (if needed)
                self.typingUserNames = typingUsers // Replace with actual logic to map IDs to names
                self.isTyping = !typingUsers.isEmpty
            }
            .store(in: &cancellables)
    }
    
    func removeListeners() {
        chatRepository?.removeListeners()
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
    
    func listenForMessages() {
        chatRepository?.listenForMessages(conversationId: conversationId)
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                case .failure(_):
                    break
                case .finished:
                    break
                }
            } receiveValue: { [weak self] messages in
                self?.messages = messages
                for message in messages {
                    if let conversationId = self?.conversationId {
                        self?.markMessageAsRead(messageId: message.id, conversationId: conversationId)
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    func markMessageAsDelivered(messageId: String, conversationId: String) {
        chatRepository?.markMessageAsDelivered(messageId: messageId, conversationId: conversationId)
            .sink { completion in
                switch completion {
                case .failure(_):
                    break
                case .finished:
                    break
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }
    
    func markMessageAsRead(messageId: String, conversationId: String) {
        chatRepository?.markMessageAsRead(messageId: messageId, conversationId: conversationId)
            .sink { completion in
                switch completion {
                case .failure(_):
                    break
                case .finished:
                    break
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }
    
    func markAllMessagesAsRead(conversationId: String) {
        chatRepository?.markAllMessagesAsRead(conversationId: conversationId, currentUserId: currentUserId)
            .sink { completion in
                switch completion {
                case .failure(_):
                    break
                case .finished:
                    break
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }
    
    func uploadMedia(fileURL: URL) {
        chatRepository?.uploadMedia(fileURL: fileURL, userId: currentUserId)
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                case .failure(_):
                    break
                case .finished:
                    break
                }
            } receiveValue: { [weak self] downloadURL in
                guard let self = self,
                      let mediaType = getMediaType(fileURL: downloadURL)
                else { return }
                
                // Determine the media type
                
                
                // Send the media message
                self.sendMediaMessage(
                    mediaURL: downloadURL.absoluteString,
                    mediaType: mediaType,
                    conversationId: self.conversationId
                )
            }
            .store(in: &cancellables)
    }
    
    func sendMediaMessage(mediaURL: String, mediaType: MediaType, conversationId: String) {
        let newMessage = Message(
            text: "", // Optional: Add a caption
            senderId: currentUserId,
            senderName: getSenderName(),
            timestamp: Date(),
            mediaURL: mediaURL,
            mediaType: mediaType
        )
        
        // Add the new message to the local state
        messages.append(newMessage)
        
        // Send the message to Firestore
        chatRepository?.sendMediaMessage(message: newMessage, conversationId: conversationId)
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                switch completion {
                case .failure(_):
                    // Remove the message from local state if Firestore fails
                    self?.messages.removeAll { $0.id == newMessage.id }
                case .finished:
                    break
                }
            } receiveValue: { _ in
                print("Media message sent successfully!")
            }
            .store(in: &cancellables)
    }
}
