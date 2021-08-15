//
//  KJBasePlayer+KJRecordTime.m
//  KJPlayer
//
//  Created by 77。 on 2021/8/15.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJBasePlayer+KJRecordTime.h"
#import <objc/runtime.h>

@interface KJBasePlayer ()

@property (nonatomic,copy,readwrite) void(^recordTimeBlock)(NSTimeInterval time);

@end

@implementation KJBasePlayer (KJRecordTime)

- (BOOL)kj_recordLastTime{
//    if (self.recordLastTime) {
//        NSString *dbid = kPlayerIntactName(self.originalURL);
//        NSTimeInterval time = [DBPlayerData kj_getLastTimeDbid:dbid];
//        kGCD_player_main(^{
//            if (self.totalTime) self.currentTime = time;
//        });
//        self.kVideoAdvanceAndReverse(time,nil);
//        if (self.recordTimeBlock) {
//            kGCD_player_main(^{
//                self.recordTimeBlock(time);
//            });
//        }
//    }
    return NO;
}

/// 主动存储当前播放记录
- (void)kj_saveRecordLastTime{
    @synchronized (self) {
        if (self.recordLastTime) {
            [DBPlayerData kj_saveRecordLastTime:self.currentTime dbid:kPlayerIntactName(self.originalURL)];
        }
    }
}

@end
