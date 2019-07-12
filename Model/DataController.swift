//
//  DataController.swift
//  VirtualTouristApp
//
//  Created by IbrahimGamal on 6/13/19.
//  Copyright © 2019 IbrahimGamal. All rights reserved.
//

import Foundation
import CoreData

class DataController {
    
    let persistentContainer:NSPersistentContainer
    
    var viewContext:NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    
    
    init(modelName:String) {
        persistentContainer = NSPersistentContainer(name: modelName)
        
        
    }
    
    
    
    func load(completion: (() -> Void)? = nil) {
        persistentContainer.loadPersistentStores { storeDescription, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            self.autoSaveViewContext()
            
            completion?()
        }
    }
}

// MARK: - Autosaving

extension DataController {
    func autoSaveViewContext(interval:TimeInterval = 30) {
        print("autosaving")
        
        guard interval > 0 else {
            print("cannot set negative autosave interval")
            return
        }
        
        if viewContext.hasChanges {
            try? viewContext.save()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            self.autoSaveViewContext(interval: interval)
        }
    }
    func save()
    {
        viewContext.performAndWait()
            {
                if self.viewContext.hasChanges
                {
                    do
                    {
                        try self.viewContext.save()
                    }
                    catch
                    {
                        fatalError("Error while saving main context: \(error)")
                    }
                    
                }
        }
    }
}
