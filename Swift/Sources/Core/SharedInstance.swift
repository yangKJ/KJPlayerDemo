//
//  SharedInstance.swift
//  KJPlayer
//
//  Created by abas on 2021/12/15.
//

import Foundation

public protocol sharedInstance {
    
}

public extension sharedInstance {
    
//    public static var sharedInstance<T: KJBasePlayer>: KJBasePlayer {
//        struct Static {
//            static let instance: T = T.init()
//        }
//        return Static.instance
//    }
    
//    let onceToken = "Hook_\(NSStringFromClass(classForCoder()))";
//    //DispatchQueue函数保证代码只被执行一次，防止又被交换回去导致得不到想要的效果
//    DispatchQueue.once(token: onceToken) {
//        let oriSel = #selector(reloadData)
//        let repSel = #selector(hook_reloadData)
//        hookInstanceMethod(of: oriSel, with: repSel);
//    }
}
