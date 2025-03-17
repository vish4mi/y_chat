//
//  ChatUser.swift
//  Y Chat
//
//  Created by Vishal on 15/03/25.
//

import FirebaseFirestoreSwift
import Foundation

struct ChatUser: Identifiable, Codable, Equatable {
    @DocumentID var id: String? // Firestore document ID
    let email: String
    let uid: String // Firebase Auth UID
    let username: String
    // Use Firestore's ServerTimestamp for dates
    @ServerTimestamp var createdAt: Date? = nil
    
    // For Firestore timestamp conversion
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case uid
        case username
        case createdAt = "created_at"
    }
    
    // Add Equatable conformance
    static func == (lhs: ChatUser, rhs: ChatUser) -> Bool {
        lhs.id == rhs.id
    }
}
