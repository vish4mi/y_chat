//
//  ChatRepository+Storage.swift
//  Y Chat
//
//  Created by Vishal on 18/03/25.
//

import Combine
import CoreData

extension ChatRepository {
    
    // MARK: - Sync Local Messages
    func syncLocalMessages() -> AnyPublisher<Void, Error> {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<MessageEntity> = MessageEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isSynced == false")
        var messages: [Message] = []
        
        return Future { [self] promise in
            do {
                let unsyncedMessages = try context.fetch(fetchRequest)
                for messageEntity in unsyncedMessages {
                    let message = Message(
                        text: messageEntity.text ?? "",
                        senderId: messageEntity.senderId ?? "",
                        senderName: messageEntity.senderName ?? "",
                        timestamp: messageEntity.timestamp ?? Date(),
                        mediaURL: messageEntity.mediaURL,
                        mediaType: MediaType(rawValue: messageEntity.mediaType ?? "")
                    )
                    
                    if messageEntity.mediaType == MediaType.other.rawValue {
                        if let conversationId = messageEntity.conversationId {
                            if messageEntity.groupId != nil {
                                self.sendGroupMessage(message: message, conversationId: conversationId)
                                    .receive(on: RunLoop.main)
                                    .sink { completion in
                                        switch completion {
                                        case .failure(_): break
                                        case .finished: break
                                        }
                                    } receiveValue: { _ in
                                        messages.append(message)
                                        messages.sort { $0.timestamp ?? Date.distantFuture < $1.timestamp ?? Date.distantFuture }
                                    }
                                    .store(in: &cancellables)
                            } else {
                                sendDirectMessage(message: message, conversationId: conversationId)
                                    .receive(on: RunLoop.main)
                                    .sink { completion in
                                        switch completion {
                                        case .failure(_): break
                                        case .finished: break
                                        }
                                    } receiveValue: { _ in
                                        messages.append(message)
                                        messages.sort { $0.timestamp ?? Date.distantFuture < $1.timestamp ?? Date.distantFuture }
                                    }
                                    .store(in: &cancellables)
                            }
                        }
                    } else {
                        if let conversationId = messageEntity.conversationId {
                            sendMediaMessage(message: message, conversationId: conversationId)
                                .receive(on: RunLoop.main)
                                .sink { completion in
                                    switch completion {
                                    case .failure(_): break
                                    case .finished: break
                                    }
                                } receiveValue: { _ in
                                    messages.append(message)
                                    messages.sort { $0.timestamp ?? Date.distantFuture < $1.timestamp ?? Date.distantFuture }
                                }
                                .store(in: &cancellables)
                        }
                    }
                }
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Save Message Locally
    private func saveMessageLocally(message: Message) -> AnyPublisher<Void, Error> {
        let context = persistentContainer.viewContext
        
        return Future { promise in
            let messageEntity = MessageEntity(context: context)
            messageEntity.id = message.id
            messageEntity.text = message.text
            messageEntity.senderId = message.senderId
            messageEntity.senderName = message.senderName
            messageEntity.timestamp = message.timestamp
            messageEntity.status = message.status.rawValue
            messageEntity.isGroupMessage = message.isGroupMessage
            messageEntity.groupId = message.groupId
            messageEntity.mediaURL = message.mediaURL
            messageEntity.mediaType = message.mediaType?.rawValue
            messageEntity.isSynced = false
            
            do {
                try context.save()
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Fetch Local Messages
    private func fetchLocalMessages(conversationId: String) -> AnyPublisher<[Message], Error> {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<MessageEntity> = MessageEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "conversationId == %@", conversationId)
        
        return Future { promise in
            do {
                let messageEntities = try context.fetch(fetchRequest)
                let messages = messageEntities.map { messageEntity in
                    if let groupId = messageEntity.groupId {
                        return Message(
                            text: messageEntity.text ?? "",
                            senderId: messageEntity.senderId ?? "",
                            senderName: messageEntity.senderName ?? "",
                            groupId: groupId,
                            mediaURL: messageEntity.mediaURL,
                            mediaType: MediaType(rawValue: messageEntity.mediaType ?? "")
                        )
                    } else {
                        return Message(
                            text: messageEntity.text ?? "",
                            senderId: messageEntity.senderId ?? "",
                            senderName: messageEntity.senderName ?? "",
                            timestamp: messageEntity.timestamp ?? Date(),
                            mediaURL: messageEntity.mediaURL,
                            mediaType: MediaType(rawValue: messageEntity.mediaType ?? "")
                        )
                    }
                }
                promise(.success(messages))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    
}
