//
//  HomeViewModel.swift
//  KJPlayerDemo_Example
//
//  Created by 77。 on 2021/12/23.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

enum ViewControllerType: String {
    case AVPlayer = "avplayer"
    
    func viewController() -> BaseViewController {
        switch self {
        case .AVPlayer: return AVPlayerViewController()
        }
    }
    var className: String {
        var string: String = "."
        switch self {
        case .AVPlayer:
            string = NSStringFromClass(AVPlayerViewController.self)
        }
        return String(string.split(separator: ".").last ?? "")
    }
}

class HomeViewModel: NSObject {

    let datas: [ViewControllerType] = {
        return [
            .AVPlayer,
        ]
    }()
}
