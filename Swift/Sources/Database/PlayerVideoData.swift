//
//  PlayerVideoData.swift
//  KJPlayer
//
//  Created by abas on 2021/12/14.
//

import Foundation
import CoreData

/// 这里之前遇见的问题，使用自定义模型时刻
/// 关于表名和模型名称一致时，报`Invalid redeclaration of 'PlayerVideoData'`
/// 解决方案：表名`Video`和模型名`PlayerVideoData`不一致即可
///
/// The problem encountered here, use custom model moments
/// When the table name and the model name are consistent, report `invalid redeclaration of'PlayerVideoData'`
/// Solution to the cause of the table name and model name
///
///
///`[PlayerVideoData setDbid:]: unrecognized selector sent to instance 0x6000006bc000 (NSInvalidArgumentException)`
/// 重新关联对象模型
/// 解决方案：
/// 记得修改`Entity`处的`Class`为对应关联模型`PlayerVideoData`
/// 将`Codegen`修改为`None`
///
/// Re-associate the object model
/// Solution:
/// Remember to modify the `Class` at `Entity` to correspond to the associated model `PlayerVideoData`
/// Modify `Codegen` to `None`
/// https://stackoverflow.com/questions/45434556/an-nsmanagedobject-of-class-classname-must-have-a-valid-nsentitydescription

@objc(PlayerVideoData)
public class PlayerVideoData: NSManagedObject {
    
    /// `ENTITIES` table name
    static let entityName = "Video"
}

extension PlayerVideoData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PlayerVideoData> {
        return NSFetchRequest<PlayerVideoData>(entityName: PlayerVideoData.entityName)
    }
    
    @nonobjc public class func insertNewObject(context: NSManagedObjectContext) -> PlayerVideoData? {
        let model = NSEntityDescription.insertNewObject(forEntityName: PlayerVideoData.entityName,
                                                        into: context) as? PlayerVideoData
        return model
    }

    /// Primary key ID, video link remove SCHEME and then MD5
    @NSManaged public var dbid: String?
    /// The primary key of the associated `Record` table
    @NSManaged public var recordID: String?
    /// Sandbox address for video storage
    @NSManaged public var sandboxPath: String?
    /// Save timestamp, convenient sorting
    @NSManaged public var saveTime: Double
    /// Video content length
    @NSManaged public var videoContentLength: Int16
    /// Video data
    @NSManaged public var videoData: Data?
    /// The video has been downloaded
    @NSManaged public var videoDownloaded: Bool
    /// Video format suffix, default `.mp4`
    @NSManaged public var videoFormat: String?
    /// Video total time
    @NSManaged public var videoTotalTime: Double
    /// Video link
    @NSManaged public var videoUrl: String?
}

extension PlayerVideoData {

    /// Get video total time
    public static func videoTotalTime(with dbid: String) -> TimeInterval {
        if let data = DatabaseManager.queryOne(with: dbid) {
            return data.videoTotalTime
        }
        return 0.0
    }
}
