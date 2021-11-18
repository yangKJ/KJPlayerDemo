//
//  HomeModel.swift
//  KJPlayer_Example
//
//  Created by 77。 on 2021/11/4.
//  Copyright © 2021 CocoaPods. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

import UIKit

@objc class HomdeModel: NSObject {
    var title: String?
    var url: String?
    var type: URLType?
    var image: UIImage?
    var isPlay: Bool = false
}

@objc public enum URLType: Int {
    case video
    case image
}
