//
//  MessageStatusView.swift
//  Y Chat
//
//  Created by Vishal on 16/03/25.
//

import SwiftUI

struct MessageStatusView: View {
    let status: MessageStatus
    
    var body: some View {
        HStack(spacing: 2) {
            switch status {
            case .sent:
                Image(systemName: "checkmark")
                    .symbolRenderingMode(.monochrome)
                    .foregroundColor(.gray)
            case .delivered:
                Image(systemName: "checkmark")
                    .symbolRenderingMode(.monochrome)
                    .foregroundColor(.gray)
                Image(systemName: "checkmark")
                    .symbolRenderingMode(.monochrome)
                    .foregroundColor(.gray)
            case .read:
                Image(systemName: "checkmark")
                    .symbolRenderingMode(.monochrome)
                    .foregroundColor(.blue)
                Image(systemName: "checkmark")
                    .symbolRenderingMode(.monochrome)
                    .foregroundColor(.blue)
            }
        }
        .font(.system(size: 10))
        .padding(2)
    }
}
