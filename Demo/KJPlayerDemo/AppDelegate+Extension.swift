//
//  AppDelegate+Extension.swift
//  KJPlayerDemo
//
//  Created by yangkejun on 2021/8/12.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

import Foundation

extension AppDelegate {
    @objc func initMonkey()  {
        #if DEBUG
        self.monkeyPaws = MonkeyPaws(view: self.window!)
        #endif
    }
}
