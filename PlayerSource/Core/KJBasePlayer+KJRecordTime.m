//
//  KJBasePlayer+KJRecordTime.m
//  KJPlayer
//
//  Created by 77。 on 2021/8/15.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJBasePlayer+KJRecordTime.h"
#import <objc/runtime.h>

@interface KJBasePlayer ()

@property (nonatomic,assign) BOOL record;
@property (nonatomic,copy,readwrite) void(^recordTimeBlock)(NSTimeInterval time);
@property (nonatomic,assign) NSTimeInterval currentTime,totalTime;

@end

@implementation KJBasePlayer (KJRecordTime)

/// 记录播放
- (BOOL)kj_recordLastTimePlayIMP{
    if (self.record) {
        NSString *dbid = kPlayerIntactName(self.originalURL);
        NSTimeInterval time = [DBPlayerData kj_getLastTimeDbid:dbid];
        kGCD_player_main(^{
            if (self.totalTime) self.currentTime = time;
        });
        self.kVideoAdvanceAndReverse(time,nil);
        if (self.recordTimeBlock) {
            kGCD_player_main(^{
                self.recordTimeBlock(time);
            });
        }
        return YES;
    }
    return NO;
}

/// 获取记录上次观看时间
/// @param record 是否需要记录观看时间
/// @param lastTime 上次播放时间回调
- (void)kj_videoRecord:(BOOL)record lastTime:(void(^)(NSTimeInterval time))lastTime{
    self.recordTimeBlock = lastTime;
    self.record = record;
}

/// 主动存储当前播放记录
- (void)kj_saveRecordLastTime{
    @synchronized (self) {
        if (self.record) {
            [DBPlayerData kj_saveRecordLastTime:self.currentTime dbid:kPlayerIntactName(self.originalURL)];
        }
    }
}

#pragma mark - Associated

- (BOOL)record{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}
- (void)setRecord:(BOOL)record{
    objc_setAssociatedObject(self, @selector(record), @(record), OBJC_ASSOCIATION_ASSIGN);
}
- (void (^)(NSTimeInterval))recordTimeBlock{
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setRecordTimeBlock:(void (^)(NSTimeInterval))recordTimeBlock{
    objc_setAssociatedObject(self, @selector(recordTimeBlock), recordTimeBlock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
