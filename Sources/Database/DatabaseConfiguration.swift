//
//  DatabaseConfiguration.swift
//  KJPlayer
//
//  Created by abas on 2021/12/14.
//

import Foundation
import CoreData

extension DatabaseManager {
    internal struct Configuration { }
    
    /// Instance objects
    /// `let data = PlayerVideoData.init(context: DatabaseManager.context)
    public static var context: NSManagedObjectContext {
        let ctx = DatabaseManager.Configuration.context()
        return ctx!
    }
}

/// Configuration information, please set in the App startup time
extension DatabaseManager.Configuration {
    /// `xcdatamodeld` database name
    static let resourceName = "APlayer"
    
    static var ctx: NSManagedObjectContext? = nil
    
    static func context() -> NSManagedObjectContext? {
        guard ctx == nil else { return ctx! }
        let url = Bundle.main.url(forResource: DatabaseManager.Configuration.resourceName,
                                  withExtension: "momd")
        guard let url = url, let model = NSManagedObjectModel(contentsOf: url) else { return nil }
        if #available(iOS 10.0, *) {
            let persisContext = NSPersistentContainer(name: PlayerVideoData.entityName, managedObjectModel: model)
            persisContext.loadPersistentStores(completionHandler: { _, _ in })
            ctx = persisContext.viewContext
        } else {
            // Fallback on earlier versions
        }
        return ctx
    }
}
