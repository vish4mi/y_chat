//
//  NewChatViewModel.swift
//  Y Chat
//
//  Created by Vishal on 15/03/25.
//

import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

class NewChatViewModel: ObservableObject {
    @Published var searchResults: [ChatUser] = []
    @Published var error: String?
    @Published var isSearching = false
    
    private let db = Firestore.firestore()
    
    func searchUsers(query: String) {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        isSearching = true
        error = nil
        
        db.collection("users")
            .whereField("email", isEqualTo: query.lowercased())
            .getDocuments { [weak self] snapshot, error in
                self?.isSearching = false
                
                if let error = error {
                    self?.error = error.localizedDescription
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    self?.error = "No user found"
                    return
                }
                
                self?.searchResults = documents.compactMap { doc in
                    try? doc.data(as: ChatUser.self)
                }
            }
    }
    
    func startChat(with user: ChatUser) {
        guard
            let currentUserID = Auth.auth().currentUser?.uid,
            let currentUserName = Auth.auth().currentUser?.displayName ?? Auth.auth().currentUser?.email // Fallback to email if name unavailable
        else { return }

        guard let userID = user.id else {
            print("Error: User ID is nil")
            return
        }

        let participants = [currentUserID, userID].sorted()
        let participantNames = [currentUserName, user.username].sorted() // Assuming ChatUser has a `name` property

        let conversationRef = Firestore.firestore()
            .collection("conversations")
            .document(participants.joined(separator: "_"))

        conversationRef.setData([
            "participants": participants,
            "participantNames": participantNames, // Changed from participantEmails
            "lastMessage": "",
            "timestamp": FieldValue.serverTimestamp(),
            "lastMessageSenderId": "",
            "isGroup": false
        ]) { error in
            if let error = error {
                print("Failed to create conversation: \(error.localizedDescription)")
            } else {
                print("Conversation created successfully!")
                // Handle navigation
            }
        }
    }
    
}
