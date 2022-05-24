//
//  PersistentContainer.swift
//  OpenLibrary
//
//  Created by Peter Wu on 7/13/19.
//  Copyright © 2019 Peter Wu. All rights reserved.
//

import UIKit
import CoreData

class PersistentContainer: NSPersistentContainer {

    func saveContext(backgroundContext: NSManagedObjectContext? = nil) {
        let context = backgroundContext ?? viewContext
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch let error as NSError {
            print("Error: \(error), \(error.userInfo)")
        }
    }
}
