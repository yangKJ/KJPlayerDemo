//
//  Function.swift
//  KJPlayer
//
//  Created by abas on 2021/12/19.
//

import Foundation

extension Common {
    internal struct Function { }
}

extension Common.Function {
    
    /// Name
    /// - Parameter url: Link
    /// - Returns: Video link remove SCHEME
    static func intactName(_ url: NSURL) -> String {
        if let resourceSpecifier = url.resourceSpecifier {
            return resourceSpecifier
        }
        if let absoluteString = url.absoluteString {
            return absoluteString
        }
        return ""
    }
    
    /// Video Aesset type
    static func videoAesset(_ url: NSURL?) -> PlayerAsset {
        guard let videoURL = url else { return .NONE }
        if let pathExtension = videoURL.pathExtension {
            if pathExtension.contains("m3u8") || pathExtension.contains("ts") {
                return .HLS
            } else {
                return .FILE
            }
        }
        let array = videoURL.path?.components(separatedBy: ".")
        if array?.count == 0 {
            return .NONE
        }
        if let last = array?.last, (last.contains("m3u8") || last.contains("ts")) {
            return .HLS
        }
        return .FILE
    }
    
    /// Convert seconds to display time string
    static func timeConvert(_ time: TimeInterval) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone(name: "GMT") as TimeZone?
        if time / 3600 >= 1 {
            dateFormatter.dateFormat = "HH:mm:ss"
        } else {
            dateFormatter.dateFormat = "mm:ss"
        }
        return dateFormatter.string(from: Date(timeIntervalSince1970: time))
    }
    
    /// Determine whether it is a network resource
    static func isOnlineResource(_ urlString: String) -> Bool {
        return urlString.starts(with: "http")
    }
}
