//
//  MessageBubble.swift
//  Y Chat
//
//  Created by Vishal on 15/03/25.
//

import SwiftUI

struct MessageBubble: View {
    let message: Message
    let isFromCurrentUser: Bool
    let showSenderName: Bool
    
    var body: some View {
        HStack {
            if isFromCurrentUser {
                Spacer() // Push to right
            }
            
            VStack(alignment: isFromCurrentUser ? .trailing : .leading, spacing: 4) {
                if showSenderName && !isFromCurrentUser {
                    Text(message.senderName)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                // Display media or text message
                if let mediaURL = message.mediaURL, let mediaType = message.mediaType {
                    // Media message (image, video, audio)
                    MediaMessageView(mediaURL: mediaURL, mediaType: mediaType)
                } else {
                    // Text message
                    Text(message.text)
                        .padding()
                        .background(isFromCurrentUser ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                }
                
                HStack(alignment: .bottom, spacing: 4) {
                    Text(message.timestamp ?? Date(), style: .time)
                        .font(.caption2)
                        .foregroundColor(.gray)
                    
                    if isFromCurrentUser {
                        MessageStatusView(status: message.status)
                    }
                }
                .frame(maxWidth: .infinity, alignment: isFromCurrentUser ? .trailing : .leading)
            }
            .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: isFromCurrentUser ? .trailing : .leading)
            
            if !isFromCurrentUser {
                Spacer() // Push to left
            }
        }
        .padding(.horizontal)
    }
}
