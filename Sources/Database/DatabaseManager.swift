//
//  DatabaseManager.swift
//  KJPlayer
//
//  Created by abas on 2021/12/14.
//

import Foundation
import CoreData

public struct DatabaseManager {
    
    @discardableResult
    public static func insert(with data: PlayerVideoData) -> Bool {
        guard let context = DatabaseManager.Configuration.context(),
              let model = PlayerVideoData.insertNewObject(context: context) else {
                  return false
              }
        model.dbid = data.dbid
        model.recordID = data.recordID ?? data.dbid
        model.sandboxPath = data.sandboxPath ?? ""
        model.saveTime = Date().timeIntervalSince1970
        model.videoContentLength = data.videoContentLength
        model.videoData = data.videoData ?? Data()
        model.videoFormat = data.videoFormat ?? ".mp4"
        model.videoDownloaded = data.videoDownloaded
        model.videoTotalTime = data.videoTotalTime
        model.videoUrl = data.videoUrl ?? ""
        do {
            try context.save()
            return true
        } catch {
            return false
        }
    }
    
    @discardableResult
    public static func update(with data: PlayerVideoData, playedTime: TimeInterval?) -> Bool {
        guard let context = DatabaseManager.Configuration.context() else { return false }
        let request = PlayerVideoData.fetchRequest()
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(PlayerVideoData.dbid), data.dbid!)
        do {
            let datas = try context.fetch(request)
            if !datas.isEmpty, let model = datas.first {
                model.recordID = data.recordID ?? data.dbid
                model.sandboxPath = data.sandboxPath ?? model.sandboxPath
                model.videoData = data.videoData ?? model.videoData
                model.videoFormat = data.videoFormat ?? model.videoFormat
                model.videoUrl = data.videoUrl ?? model.videoUrl
                model.videoDownloaded = model.videoDownloaded == data.videoDownloaded ?
                model.videoDownloaded : model.videoDownloaded
                if data.saveTime > 0 { model.saveTime = data.saveTime }
                if data.videoContentLength > 0 { model.videoContentLength = data.videoContentLength }
                if data.videoTotalTime > 0 { model.videoTotalTime = data.videoTotalTime }
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
    public static func queryOne(with dbid: String) -> PlayerVideoData? {
        let datas = DatabaseManager.query(with: dbid)
        if datas.isEmpty {
            return nil
        } else {
            return datas.first
        }
    }
    
    @discardableResult
    public static func query(with dbid: String) -> [PlayerVideoData] {
        guard let context = DatabaseManager.Configuration.context() else { return [] }
        let request = PlayerVideoData.fetchRequest()
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(PlayerVideoData.dbid), dbid)
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
        let request = PlayerVideoData.fetchRequest()
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(PlayerVideoData.dbid), dbid)
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
