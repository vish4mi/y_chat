//
//  FirestoreChatRequest.swift
//  Y Chat
//
//  Created by Vishal on 18/03/25.
//

import Combine
import FirebaseFirestore
import FirebaseFirestoreSwift

class FirestoreChatRequest: ChatRequestProtocol {
    private var listener: ListenerRegistration?
    
    func fetchConversation(conversationId: String) -> AnyPublisher<Conversation?, Error> {
        return Future { promise in
            Firestore.firestore()
                .collection("conversations")
                .document(conversationId)
                .addSnapshotListener { snapshot, error in
                    if let error = error {
                        promise(.failure(error))
                    } else {
                        let conversation = try? snapshot?.data(as: Conversation.self)
                        promise(.success(conversation))
                    }
                }
        }
        .eraseToAnyPublisher()
    }
    
    func fetchMessages(conversationId: String) -> AnyPublisher<[Message], Error> {
        return Future { promise in
            self.listener = Firestore.firestore()
                .collection("conversations")
                .document(conversationId)
                .collection("messages")
                .order(by: "timestamp")
                .addSnapshotListener { snapshot, error in
                    if let error = error {
                        promise(.failure(error))
                    } else {
                        guard let documents = snapshot?.documents else {
                            promise(.success([]))
                            return
                        }
                        
                        let messages = documents.compactMap { try? $0.data(as: Message.self) }
                        promise(.success(messages))
                    }
                }
        }
        .eraseToAnyPublisher()
    }
    
    func sendDirectMessage(message: Message, conversationId: String) -> AnyPublisher<Void, Error> {
        return Future { promise in
            do {
                try Firestore.firestore()
                    .collection("conversations")
                    .document(conversationId)
                    .collection("messages")
                    .document(message.id)
                    .setData(from: message)
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func sendGroupMessage(message: Message, conversationId: String) -> AnyPublisher<Void, Error> {
        return Future { promise in
            do {
                try Firestore.firestore()
                    .collection("conversations")
                    .document(conversationId)
                    .collection("messages")
                    .document(message.id)
                    .setData(from: message)
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func updateLastMessage(message: Message, conversationId: String) -> AnyPublisher<Void, Error> {
        let updateData: [String: Any] = [
            "lastMessage": message.text,
            "lastMessageSenderId": message.senderId,
            "lastMessageSenderName": message.senderName,
            "timestamp": FieldValue.serverTimestamp()
        ]
        
        return Future { promise in
            Firestore.firestore()
                .collection("conversations")
                .document(conversationId)
                .updateData(updateData) { error in
                    if let error = error {
                        promise(.failure(error))
                    } else {
                        promise(.success(()))
                    }
                }
        }
        .eraseToAnyPublisher()
    }
    
    func updateTypingStatus(isTyping: Bool, conversationId: String, currentUserId: String) -> AnyPublisher<Void, Error> {
        return Future { promise in
            let typingData: [String: Any] = [
                "userId": currentUserId,
                "isTyping": isTyping,
                "timestamp": FieldValue.serverTimestamp() // Optional: Track when the status was updated
            ]
            
            Firestore.firestore()
                .collection("conversations")
                .document(conversationId)
                .collection("typing")
                .document(currentUserId) // Use the user ID as the document ID
                .setData(typingData, merge: true) { error in
                    if let error = error {
                        promise(.failure(error))
                    } else {
                        promise(.success(()))
                    }
                }
        }
        .eraseToAnyPublisher()
    }
    
    func observeTyping(conversationId: String, currentUserId: String) -> AnyPublisher<[String], Error> {
        let subject = PassthroughSubject<[String], Error>()
        
        self.listener = Firestore.firestore()
            .collection("conversations")
            .document(conversationId)
            .collection("typing")
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    subject.send(completion: .failure(error)) // Emit error
                } else {
                    let typingUsers = snapshot?.documents
                        .compactMap { doc -> String? in
                            guard doc["isTyping"] as? Bool == true,
                                  let userId = doc["userId"] as? String,
                                  userId != currentUserId
                            else { return nil }
                            return userId
                        } ?? []
                    subject.send(typingUsers) // Emit updated typing users
                }
            }
        
        return subject
            .eraseToAnyPublisher()
    }
    
    func markMessageAsDelivered(messageId: String, conversationId: String) -> AnyPublisher<Void, Error> {
        return Future { promise in
            Firestore.firestore()
                .collection("conversations")
                .document(conversationId)
                .collection("messages")
                .document(messageId)
                .updateData(["status": "delivered"]) { error in
                    if let error = error {
                        promise(.failure(error))
                    } else {
                        promise(.success(()))
                    }
                }
        }
        .eraseToAnyPublisher()
    }
    
    func markMessageAsRead(messageId: String, conversationId: String) -> AnyPublisher<Void, Error> {
        return Future { promise in
            Firestore.firestore()
                .collection("conversations")
                .document(conversationId)
                .collection("messages")
                .document(messageId)
                .updateData(["status": "read"]) { error in
                    if let error = error {
                        promise(.failure(error))
                    } else {
                        promise(.success(()))
                    }
                }
        }
        .eraseToAnyPublisher()
    }
    
    func markAllMessagesAsRead(conversationId: String, currentUserId: String) -> AnyPublisher<Void, Error> {
        return Future { promise in
            Firestore.firestore()
                .collection("conversations")
                .document(conversationId)
                .collection("messages")
                .whereField("status", in: ["sent", "delivered"])
                .whereField("senderId", isNotEqualTo: currentUserId)
                .getDocuments { snapshot, error in
                    if let error = error {
                        promise(.failure(error))
                        return
                    }
                    
                    guard let documents = snapshot?.documents else {
                        promise(.success(()))
                        return
                    }
                    
                    let batch = Firestore.firestore().batch()
                    for document in documents {
                        batch.updateData(["status": "read"], forDocument: document.reference)
                    }
                    
                    batch.commit { error in
                        if let error = error {
                            promise(.failure(error))
                        } else {
                            promise(.success(()))
                        }
                    }
                }
        }
        .eraseToAnyPublisher()
    }
    
    func sendMediaMessage(
        mediaURL: String,
        mediaType: MediaType,
        conversationId: String,
        currentUserId: String, senderName: String
    ) -> AnyPublisher<Void, Error> {
        let message = Message(
            text: "",
            senderId: currentUserId,
            senderName: senderName,
            timestamp: Date(),
            mediaURL: mediaURL,
            mediaType: mediaType
        )
        
        return Future { promise in
            do {
                try Firestore.firestore()
                    .collection("conversations")
                    .document(conversationId)
                    .collection("messages")
                    .document(message.id)
                    .setData(from: message) { error in
                        if let error = error {
                            promise(.failure(error))
                        } else {
                            promise(.success(()))
                        }
                    }
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func listenForMessages(conversationId: String) -> AnyPublisher<[Message], Error> {
        let subject = PassthroughSubject<[Message], Error>()
        
        self.listener = Firestore.firestore()
            .collection("conversations")
            .document(conversationId)
            .collection("messages")
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    subject.send(completion: .failure(error)) // Emit error
                }
                
                guard let documents = snapshot?.documents else {
                    return
                }
                
                let messages = documents.compactMap { try? $0.data(as: Message.self) }
                subject.send(messages)
            }
        return subject
            .eraseToAnyPublisher()
    }
    
    
    func sendMediaMessage(message: Message, conversationId: String) -> AnyPublisher<Void, Error> {
        return Future { promise in
            do {
                try Firestore.firestore()
                    .collection("conversations")
                    .document(conversationId)
                    .collection("messages")
                    .document(message.id)
                    .setData(from: message) { error in
                        if let error = error {
                            promise(.failure(error))
                        } else {
                            promise(.success(()))
                        }
                    }
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func removeListeners() {
        listener?.remove()
    }
    
    deinit {
        listener?.remove()
    }
    
    func fetchConversations(userId: String) -> AnyPublisher<[Conversation], Error> {
        return Future { promise in
            Firestore.firestore()
                .collection("conversations")
                .whereField("participants", arrayContains: userId)
                .addSnapshotListener { snapshot, error in
                    if let error = error {
                        promise(.failure(error))
                    } else {
                        let conversations = snapshot?.documents.compactMap { doc in
                            try? doc.data(as: Conversation.self)
                        } ?? []
                        promise(.success(conversations))
                    }
                }
        }
        .eraseToAnyPublisher()
    }
    
    func listenForLastMessage(conversationId: String) -> AnyPublisher<Message, Error> {
        let subject = PassthroughSubject<Message, Error>()
        
        listener = Firestore.firestore()
            .collection("conversations")
            .document(conversationId)
            .collection("messages")
            .order(by: "timestamp", descending: true)
            .limit(to: 1)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    subject.send(completion: .failure(error))
                } else if let doc = snapshot?.documents.first,
                          let message = try? doc.data(as: Message.self) {
                    subject.send(message)
                }
            }
        
        return subject
            .handleEvents(receiveCancel: {
                self.listener?.remove()
            })
            .eraseToAnyPublisher()
    }
}
