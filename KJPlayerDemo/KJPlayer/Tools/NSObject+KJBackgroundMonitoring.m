//
//  NSObject+KJBackgroundMonitoring.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2019/9/4.
//  Copyright © 2019 杨科军. All rights reserved.
//

#import "NSObject+KJBackgroundMonitoring.h"

@interface NSObject ()
// 是否需要前后台回调
@property (nonatomic, assign) BOOL needGround;
@property (nonatomic, strong) KJBackgroundMonitoringBlock xxblock;
@end

@implementation NSObject (KJBackgroundMonitoring)
#pragma mark - public
// 注册进入后台 进入前台事件
- (void)registergroundBlock:(KJBackgroundMonitoringBlock)block {
    @synchronized(self) {
        self.xxblock = block;
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
    !self.xxblock?:self.xxblock(NO);
}

- (void)applicationEnterBackground {
    !self.xxblock?:self.xxblock(YES);
}

- (BOOL)needGround {
    return objc_getAssociatedObject(self, @selector(needGround));
}
- (void)setNeedGround:(BOOL)needGround {
    objc_setAssociatedObject(self, @selector(needGround), @(needGround), OBJC_ASSOCIATION_ASSIGN);
}
- (KJBackgroundMonitoringBlock)xxblock {
    return objc_getAssociatedObject(self, @selector(xxblock));
}
- (void)setXxblock:(KJBackgroundMonitoringBlock)xxblock {
    objc_setAssociatedObject(self, @selector(xxblock), xxblock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
