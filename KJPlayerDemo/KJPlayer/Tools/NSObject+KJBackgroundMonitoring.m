//
//  NSObject+KJBackgroundMonitoring.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2019/9/4.
//  Copyright © 2019 杨科军. All rights reserved.
//

#import "NSObject+KJBackgroundMonitoring.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

static void *DirectionMonitoringBlockKey = &DirectionMonitoringBlockKey;
static void *DirectionNeedGroundKey = &DirectionNeedGroundKey;
static void *DirectionIsBackgroundKey = &DirectionIsBackgroundKey;

@interface NSObject ()
// 是否需要前后台回调
@property (nonatomic, assign) BOOL needGround;
@property (nonatomic, assign) BOOL isBackground;
@property (nonatomic, strong) BackgroundMonitoringBlock monitoringBlock;

@end

@implementation NSObject (KJBackgroundMonitoring)
#pragma mark - public
// 注册进入后台 进入前台事件
- (void)registergroundBlock:(void(^)(BOOL isBackground))monitoringBlock {
    @synchronized(self) {
        self.monitoringBlock = monitoringBlock;
        self.needGround = YES;
    }
    [self setupgroundNotificationCenter];
}

// 继续前后台监听
- (void)resumegroundListen {
    @synchronized(self) {
        self.needGround = YES;
    }
}

// 暂停前后台监听
- (void)pausegroundListen {
    @synchronized(self) {
        self.needGround = NO;
    }
}

#pragma mark - private
- (void)setupgroundNotificationCenter {
    dispatch_async(dispatch_get_main_queue(), ^{
        // app从后台进入前台都会调用这个方法
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationBecomeActive) name:UIApplicationWillEnterForegroundNotification object:nil];
        // 添加检测app进入后台的观察者
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationEnterBackground) name: UIApplicationDidEnterBackgroundNotification object:nil];
    });
}

- (void)applicationBecomeActive {
    self.isBackground = NO;
    if (self.monitoringBlock) {
        self.monitoringBlock(NO);
    }
}

- (void)applicationEnterBackground {
    self.isBackground = YES;
    if (self.monitoringBlock) {
        self.monitoringBlock(YES);
    }
}

- (void)setNeedGround:(BOOL)needGround {
    objc_setAssociatedObject(self, &DirectionNeedGroundKey, @(needGround), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)needGround {
    return objc_getAssociatedObject(self, &DirectionNeedGroundKey);
}

- (void)setMonitoringBlock:(BackgroundMonitoringBlock)monitoringBlock {
    objc_setAssociatedObject(self, &DirectionMonitoringBlockKey, monitoringBlock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BackgroundMonitoringBlock)monitoringBlock {
    return objc_getAssociatedObject(self, &DirectionMonitoringBlockKey);
}

@end
