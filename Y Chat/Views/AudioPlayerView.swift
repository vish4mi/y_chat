//
//  AudioPlayerView.swift
//  Y Chat
//
//  Created by Vishal on 17/03/25.
//

import SwiftUI
import AVKit

struct AudioPlayerView: View {
    let url: String
    
    @State private var player: AVPlayer?
    @State private var isPlaying = false
    
    var body: some View {
        HStack {
            Button(action: togglePlayback) {
                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 30))
                    .foregroundColor(.blue)
            }
            
            Text("Audio Message")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
        .onAppear {
            if let audioURL = URL(string: url) {
                player = AVPlayer(url: audioURL)
            }
        }
    }
    
    private func togglePlayback() {
        if isPlaying {
            player?.pause()
        } else {
            player?.play()
        }
        isPlaying.toggle()
    }
}
