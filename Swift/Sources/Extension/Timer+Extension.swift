//
//  Timer+Extension.swift
//  KJPlayer
//
//  Created by abas on 2021/12/18.
//

import Foundation

/// 已解决循环引用的计时器
/// Circular referenced timers resolved
public extension Timer {
    
    /// Circular referenced timers resolved
    /// - Parameters:
    ///  - interval: time interval
    ///  - repeats: whether to repeat
    ///  - block: callback response
    /// - Returns: timer
    @discardableResult
    class func kj_scheduledTimer(withTimeInterval interval: TimeInterval,
                                 repeats: Bool,
                                 block: @escaping (_ timer: Timer) -> Void) -> Timer {
        if #available(iOS 10.0, *) {
            return Timer.scheduledTimer(withTimeInterval: interval, repeats: repeats, block: block)
        }
        return scheduledTimer(timeInterval: interval,
                              target: self,
                              selector: #selector(handerTimerAction(sender:)),
                              userInfo: TimerBlock(block),
                              repeats: repeats)
    }
    
    ///`[NSTimer handerTimerAction:]: unrecognized selector sent to class 0x1105c30c0'
    /// Timer is a class object, you can only call class methods, not instance methods
    @objc private class func handerTimerAction(sender: Timer) {
        if let block = sender.userInfo as? TimerBlock<(Timer) -> Void> {
            block.type(sender)
        }
    }
    
    private struct TimerBlock<T> {
        let type: T
        init(_ type: T) {
            self.type = type
        }
    }
}

/*
 Ex:
 
 self.timer = Timer.kj_scheduledTimer(withTimeInterval: time ?? 1,
                                      repeats: true,
                                      block: { [weak self] (timer) in
     guard let `self` = self else { return }
     // do something...
 })
 */
