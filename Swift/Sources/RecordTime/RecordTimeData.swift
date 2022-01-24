//
//  RecordTimeData.swift
//  KJPlayer
//
//  Created by abas on 2021/12/18.
//

import Foundation
import CoreData

@objc(RecordTimeData)
public class RecordTimeData: NSManagedObject {
    
    /// `ENTITIES` table name
    static let entityName = "Record"

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RecordTimeData> {
        return NSFetchRequest<RecordTimeData>(entityName: RecordTimeData.entityName)
    }
    
    @nonobjc public class func insertNewObject(context: NSManagedObjectContext) -> RecordTimeData? {
        let model = NSEntityDescription.insertNewObject(forEntityName: RecordTimeData.entityName,
                                                        into: context) as? RecordTimeData
        return model
    }

    /// Primary key ID, video link remove SCHEME and then MD5
    @NSManaged public var dbid: String?
    /// Video played time
    @NSManaged public var lastTime: Double
    /// Video total time
    @NSManaged public var totalTime: Double
}

extension RecordTimeData {
    internal struct DB { }
    
    /// Record the last play time
    /// - Parameters:
    ///  - time: Current playing time, If it is empty, the played time will be reset
    ///  - total: Video total time
    ///  - dbid: Primary key ID
    /// - Returns: whether succeed
    @discardableResult
    public static func savePlayedTime(_ time: TimeInterval?, total: TimeInterval, dbid: String) -> Bool {
        if let data = RecordTimeData.DB.queryOne(with: dbid) {
            data.lastTime = time ?? 0.0
            data.totalTime = total
            return RecordTimeData.DB.update(with: data)
        }
        let data = RecordTimeData.init(context: DatabaseManager.context)
        data.dbid = dbid
        data.lastTime = time ?? 0.0
        data.totalTime = total
        return RecordTimeData.DB.insert(with: data)
    }

    /// Get last played time and total time
    /// - Parameter dbid: Primary key ID
    /// - Returns: Played time
    public static func lastPlayTime(with dbid: String) -> (total: TimeInterval, lastTime: TimeInterval) {
        if let data = RecordTimeData.DB.queryOne(with: dbid) {
            return (data.totalTime, data.lastTime)
        }
        return (0.0, 0.0)
    }
}

extension RecordTimeData.DB {
    
    @discardableResult
    public static func insert(with data: RecordTimeData) -> Bool {
        guard let context = DatabaseManager.Configuration.context(),
              let model = RecordTimeData.insertNewObject(context: context) else {
                  return false
              }
        model.dbid = data.dbid
        model.lastTime = data.lastTime
        model.totalTime = data.totalTime
        do {
            try context.save()
            return true
        } catch {
            return false
        }
    }
    
    @discardableResult
    public static func update(with data: RecordTimeData) -> Bool {
        guard let context = DatabaseManager.Configuration.context() else { return false }
        let request = RecordTimeData.fetchRequest()
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(RecordTimeData.dbid), data.dbid!)
        do {
            let datas = try context.fetch(request)
            if !datas.isEmpty, let model = datas.first {
                model.lastTime = data.lastTime
                model.totalTime = data.totalTime
                if context.hasChanges {
                    do {
                        try context.save()
                        return true
                    } catch { }
                }
            }
        } catch { }
        return false
    }
    
    @discardableResult
    public static func queryOne(with dbid: String) -> RecordTimeData? {
        let datas = RecordTimeData.DB.query(with: dbid)
        if datas.isEmpty {
            return nil
        } else {
            return datas.first
        }
    }
    
    @discardableResult
    public static func query(with dbid: String) -> [RecordTimeData] {
        guard let context = DatabaseManager.Configuration.context() else { return [] }
        let request = RecordTimeData.fetchRequest()
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(RecordTimeData.dbid), dbid)
        do {
            let datas = try context.fetch(request)
            return datas
        } catch {
            return []
        }
    }
    
    @discardableResult
    public static func delete(with dbid: String) -> Bool {
        guard let context = DatabaseManager.Configuration.context() else { return false }
        let request = RecordTimeData.fetchRequest()
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(RecordTimeData.dbid), dbid)
        do {
            let datas = try context.fetch(request)
            for data in datas {
                context.delete(data)
            }
            if context.hasChanges {
                do {
                    try context.save()
                    return true
                } catch { }
            }
        } catch { }
        return false
    }
}
