//
//  GroupTypingIndicator.swift
//  Y Chat
//
//  Created by Vishal on 16/03/25.
//

import SwiftUI

struct GroupTypingIndicator: View {
    let names: [String]
    
    var body: some View {
        HStack(spacing: 4) {
            // Display names and typing text
            Text(typingText)
                .font(.caption)
                .lineLimit(1)
            DotAnimationView()
        }
        .foregroundColor(.gray)
    }
    
    // Computed property to generate the correct typing text
    private var typingText: String {
        let typingCount = names.count
        
        // Handle no users typing (shouldn't happen, but just in case)
        if typingCount == 0 {
            return ""
        }
        
        // Handle single user typing
        if typingCount == 1 {
            let name = names.first ?? "Someone"
            return "\(name) is typing"
        }
        
        // Handle multiple users typing
        let namesText = names.prefix(2).joined(separator: ", ")
        let suffix = typingCount > 2 ? " and others" : ""
        return "\(namesText)\(suffix) are typing"
    }
}
