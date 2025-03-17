//
//  Message.swift
//  Y Chat
//
//  Created by Vishal on 15/03/25.
//

import FirebaseFirestoreSwift
import Foundation

struct Message: Identifiable, Codable, Equatable {
    let id: String
    let text: String
    let senderId: String
    let senderName: String
    @ServerTimestamp var timestamp: Date?
    var status: MessageStatus
    var isGroupMessage: Bool = false
    var groupId: String?
    
    // Media support
    var mediaURL: String? // URL of the media file (image, video, audio)
    var mediaType: MediaType? // Type of media (image, video, audio)
    
    // For group messages
    init(
        text: String,
        senderId: String,
        senderName: String,
        groupId: String,
        timestamp: Date = Date(),
        mediaURL: String = "",
        mediaType: MediaType = .image
    ) {
        self.id = UUID().uuidString
        self.text = text
        self.senderId = senderId
        self.senderName = senderName
        self.status = .sent
        self.isGroupMessage = true
        self.groupId = groupId
        self.timestamp = timestamp
        self.mediaURL = mediaURL
        self.mediaType = mediaType
    }
    
    // For 1:1 messages
    init(
        text: String,
        senderId: String,
        senderName: String,
        timestamp: Date = Date(),
        mediaURL: String = "",
        mediaType: MediaType = .image
    ) {
        self.id = UUID().uuidString
        self.text = text
        self.senderId = senderId
        self.senderName = senderName
        self.status = .sent
        self.isGroupMessage = false
        self.groupId = nil
        self.timestamp = timestamp
        self.mediaURL = mediaURL
        self.mediaType = mediaType
    }
}
