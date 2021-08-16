//
//  KJBasePlayer+KJTryTime.m
//  KJPlayer
//
//  Created by 77。 on 2021/8/16.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJBasePlayer+KJTryTime.h"

@interface KJBasePlayer ()

@property (nonatomic,copy,readwrite) KJPlayerLookendBlock tryTimeBlock;
@property (nonatomic,assign) BOOL tryLooked;
@property (nonatomic,assign) NSTimeInterval tryTime;
@property (nonatomic,assign) NSTimeInterval currentTime;
@property (nonatomic,assign) NSTimeInterval totalTime;

@end

@implementation KJBasePlayer (KJTryTime)

- (BOOL)kj_tryTimePlayIMP:(NSTimeInterval)time{
    return [self kj_tryLook:time];
}

/// 免费试看时间和试看结束回调
/// @param time 试看时间，默认零不限制
/// @param lookend 试看结束回调
- (void)kj_tryLookTime:(NSTimeInterval)time lookend:(KJPlayerLookendBlock)lookend{
    self.tryTime = time;
    self.tryTimeBlock = lookend;
}

/// 试看处理
- (BOOL)kj_tryLook:(NSTimeInterval)time{
    if (self.totalTime == 0) {
        self.currentTime = 0;
        self.tryLooked = NO;
        return NO;
    }
    if (time >= self.tryTime && self.tryTime) {
        self.currentTime = self.tryTime;
        if (self.tryLooked == NO) {
            self.tryLooked = YES;
            kGCD_player_main(^{
                if (self.tryTimeBlock) self.tryTimeBlock(self);
            });
        }
    } else {
        self.currentTime = time;
        self.tryLooked = NO;
    }
    return self.tryLooked;
}

#pragma mark - Associated

- (KJPlayerLookendBlock)tryTimeBlock{
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setTryTimeBlock:(KJPlayerLookendBlock)tryTimeBlock{
    objc_setAssociatedObject(self, @selector(tryTimeBlock), tryTimeBlock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
