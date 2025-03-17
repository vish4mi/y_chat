//
//  Helper.swift
//  Y Chat
//
//  Created by Vishal on 17/03/25.
//

import UniformTypeIdentifiers

func getMediaType(fileURL: URL) -> MediaType? {
    // Get the file extension
    let fileExtension = fileURL.pathExtension.lowercased()
    
    // Determine the media type using UTType
    if let utType = UTType(filenameExtension: fileExtension) {
        if utType.conforms(to: .image) {
            return .image
        } else if utType.conforms(to: .movie) {
            return .video
        } else if utType.conforms(to: .audio) {
            return .audio
        }
    }
    
    // If the file type is unsupported, return nil
    print("Unsupported file type: \(fileExtension)")
    return nil
}

