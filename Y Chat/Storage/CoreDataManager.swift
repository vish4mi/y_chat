//
//  CoreDataManager.swift
//  Y Chat
//
//  Created by Vishal on 17/03/25.
//

import Foundation
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    
    private init() {
        // Register the ParticipantsTransformer
        ValueTransformer.setValueTransformer(
            ParticipantsTransformer(),
            forName: NSValueTransformerName("ParticipantsTransformer")
        )
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ChatAppModel")
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func saveMessage(message: Message) {
        let context = persistentContainer.viewContext
        let messageEntity = MessageEntity(context: context)
        messageEntity.id = message.id
        messageEntity.text = message.text
        messageEntity.senderId = message.senderId
        messageEntity.timestamp = message.timestamp
        messageEntity.status = message.status.rawValue
        messageEntity.mediaURL = message.mediaURL
        messageEntity.mediaType = message.mediaType?.rawValue
        messageEntity.isSynced = NetworkMonitor.shared.isOnline
        
        do {
            try context.save()
        } catch {
            print("Error saving message to Core Data: \(error.localizedDescription)")
        }
    }
    
    func saveMessages(messages: [Message]) {
        for message in messages {
            saveMessage(message: message)
        }
    }
    
    func fetchMessages(conversationId: String) -> [Message] {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<MessageEntity> = MessageEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "conversationId == %@", conversationId)
        
        do {
            let messageEntities = try context.fetch(fetchRequest)
            return messageEntities.map { messageEntity in
                Message(
                    text: messageEntity.text ?? "",
                    senderId: messageEntity.senderId ?? "",
                    senderName: messageEntity.senderName ?? "",
                    timestamp: messageEntity.timestamp ?? Date(),
                    mediaURL: messageEntity.mediaURL ?? "",
                    mediaType: MediaType(rawValue: messageEntity.mediaType ?? "") ?? .image
                )
            }
        } catch {
            print("Error fetching messages from Core Data: \(error.localizedDescription)")
            return []
        }
    }
}
