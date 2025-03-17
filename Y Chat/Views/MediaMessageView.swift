//
//  MediaMessageView.swift
//  Y Chat
//
//  Created by Vishal on 17/03/25.
//

import SwiftUI
import AVKit

struct MediaMessageView: View {
    let mediaURL: String
    let mediaType: MediaType
    
    var body: some View {
        Group {
            switch mediaType {
            case .image:
                AsyncImage(url: URL(string: mediaURL)) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 200, maxHeight: 200)
                            .cornerRadius(10)
                    } else if phase.error != nil {
                        Text("Failed to load media file")
                            .foregroundColor(.red)
                    } else {
                        ProgressView() // Show a loading indicator
                    }
                }
            case .video:
                VideoPlayer(player: AVPlayer(url: URL(string: mediaURL)!))
                    .frame(width: 200, height: 200)
                    .cornerRadius(10)
            case .audio:
                AudioPlayerView(url: mediaURL)
            }
        }
    }
}
