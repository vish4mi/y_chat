//
//  CoreDataStack.swift
//  Y Chat
//
//  Created by Vishal on 12/03/25.
//

import CoreData

class CoreDataStack: ObservableObject {
    static let shared = CoreDataStack()
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ChatAppModel")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("CoreData load error: \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    func saveContext() {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            print("CoreData save error: \(error)")
        }
    }
}
