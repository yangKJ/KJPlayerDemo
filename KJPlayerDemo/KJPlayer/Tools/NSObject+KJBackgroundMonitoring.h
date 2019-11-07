//
//  NSObject+KJBackgroundMonitoring.h
//  KJPlayerDemo
//
//  Created by 杨科军 on 2019/9/4.
//  Copyright © 2019 杨科军. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^KJBackgroundMonitoringBlock)(BOOL isBackground);

@interface NSObject (KJBackgroundMonitoring)

/** 注册进入后台 进入前台事件 */
- (void)registergroundBlock:(KJBackgroundMonitoringBlock)block;
/** 继续前后台监听 */
- (void)resumegroundListen;
/** 暂停前后台监听 */
- (void)pausegroundListen;

@end

NS_ASSUME_NONNULL_END
