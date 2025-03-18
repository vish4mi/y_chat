//
//  FirebaseMediaRequest.swift
//  Y Chat
//
//  Created by Vishal on 18/03/25.
//

import Combine
import FirebaseStorage
import Foundation

class FirebaseMediaRequest: MediaRequestProtocol {
    
    func uploadMedia(fileURL: URL, userId: String) -> AnyPublisher<URL, Error> {
        return Future { promise in
            // Generate a unique file name
            let fileName = "\(UUID().uuidString)_\(fileURL.lastPathComponent)"
            
            // Create a reference to the file in Firebase Storage
            let storageRef = Storage.storage().reference().child("media/\(userId)/\(fileName)")
            
            // Upload the file
            storageRef.putFile(from: fileURL, metadata: nil) { metadata, error in
                if let error = error {
                    promise(.failure(error))
                    return
                }
                
                // Get the download URL
                storageRef.downloadURL { url, error in
                    if let error = error {
                        promise(.failure(error))
                        return
                    }
                    
                    if let downloadURL = url {
                        promise(.success(downloadURL))
                    } else {
                        promise(.failure(NSError(
                            domain: "MediaError",
                            code: -1,
                            userInfo: [NSLocalizedDescriptionKey: "Failed to get download URL"]
                        )))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
