//
//  HomeViewModel.swift
//  KJPlayer_Example
//
//  Created by 77。 on 2021/11/4.
//  Copyright © 2021 CocoaPods. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

import UIKit
import Foundation
import FSPagerView
import KJPlayer

class HomeViewModel: NSObject {

    public var homeDatas: [HomdeModel] = []
    
    typealias DataBlock = () -> Void
    public var updateDataBlock: DataBlock?
    
    public let transformerNames: [String] = {
        return [
            "cross fading",
            "zoom out",
            "depth",
            "linear",
            "overlap",
            "ferris wheel",
            "inverted ferris wheel",
            "cover flow",
            "cubic"
        ]
    }()
    
    public let transformerTypes: [FSPagerViewTransformerType] = {
        return [
            .crossFading,
            .zoomOut,
            .depth,
            .linear,
            .overlap,
            .ferrisWheel,
            .invertedFerrisWheel,
            .coverFlow,
            .cubic
        ]
    }()
    
    public func loadDatas() {
        let array = [
            "https://mp4.vjshi.com/2017-11-21/7c2b143eeb27d9f2bf98c4ab03360cfe.mp4",
            "https://mp4.vjshi.com/2018-03-30/1f36dd9819eeef0bc508414494d34ad9.mp4",
            "luoza.jpeg", nil, nil,
            "https://mp4.vjshi.com/2020-12-27/a86e0cb5d0ea55cd4864a6fc7609dce8.mp4",
            "https://mp4.vjshi.com/2020-09-27/542926a8c2a99808fc981d46c1dc6aef.mp4",
        ]
        let source = array.compactMap { $0 } // 祛除空数据
        let group = DispatchGroup()
        for name in source {
            let model = HomdeModel()
            if name.hasSuffix(".mp4") {
                model.type = .video
                group.enter()
                KJScreenshotsManager.kj_placeholderImage(withTime: 7, url: name) { image in
                    model.image = image
                    group.leave()
                }
            } else {
                model.type = .image
                model.image = UIImage.init(named: name)
            }
            model.url = name
            if let URL = NSURL.init(string: name) {
                model.title = URL.lastPathComponent
            } else {
                model.title = name
            }
            self.homeDatas.append(model)
        }
        group.notify(queue: .main) {
            self.updateDataBlock?()
        }
    }
    
}

//    DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) { [self] in
//        let images = ["8","timg-2","luoza.jpeg"]
//        for index in 0..<3 {
//            let name = source[index];
//            let model = HomdeModel()
//            if name.hasSuffix(".mp4") {
//                model.type = .video
//                model.url = Bundle.main.path(forResource: name, ofType: nil)
//            } else {
//                model.type = .image
//                model.url = name
//            }
//            model.image = UIImage.init(named: images[index])
//            model.title = name
//            self.homeDatas.append(model)
//        }
//        DispatchQueue.main.async {
//            self.updateDataBlock?()
//        }
//    }
