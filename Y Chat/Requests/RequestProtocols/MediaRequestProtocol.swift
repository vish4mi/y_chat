//
//  MediaRequestProtocol.swift
//  Y Chat
//
//  Created by Vishal on 18/03/25.
//

import Combine
import FirebaseStorage
import Foundation

protocol MediaRequestProtocol {
    func uploadMedia(fileURL: URL, userId: String) -> AnyPublisher<URL, Error>
}
