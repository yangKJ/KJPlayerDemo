//
//  KJBasePlayer+KJRecordTime.m
//  KJPlayer
//
//  Created by 77。 on 2021/8/15.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJBasePlayer+KJRecordTime.h"
#import <objc/runtime.h>
#import "DBPlayerDataManager.h"

@interface KJBasePlayer ()

@property (nonatomic,assign) BOOL record;
@property (nonatomic,assign) NSTimeInterval currentTime;

@end

@implementation KJBasePlayer (KJRecordTime)

/// 记录播放
- (BOOL)kj_recordLastTimePlayIMP{
    if (self.record) {
        NSString *dbid = kPlayerIntactName(self.originalURL);
        NSTimeInterval time = [DBPlayerData kj_lastTimeWithDbid:dbid];
        PLAYER_WEAKSELF;
        kGCD_player_main(^{
            if (weakself.totalTime) weakself.currentTime = time;
        });
        [self kj_appointTime:time];
        if ([self.recordDelegate respondsToSelector:@selector(kj_recordTimeWithPlayer:totalTime:lastTime:)]) {
            kGCD_player_main(^{
                [weakself.recordDelegate kj_recordTimeWithPlayer:weakself
                                                       totalTime:weakself.totalTime
                                                        lastTime:time];
            });
        }
        return YES;
    }
    return NO;
}

/// 存储播放时间
- (void)kj_recordTimeSaveIMP{
    [self kj_saveRecordLastTime];
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

- (id<KJPlayerRecordDelegate>)recordDelegate{
    return  objc_getAssociatedObject(self, _cmd);
}
- (void)setRecordDelegate:(id<KJPlayerRecordDelegate>)recordDelegate{
    objc_setAssociatedObject(self, @selector(recordDelegate), recordDelegate, OBJC_ASSOCIATION_ASSIGN);
    if ([recordDelegate respondsToSelector:@selector(kj_recordTimeWithPlayer:)]) {
        self.record = [recordDelegate kj_recordTimeWithPlayer:self];
    }
}

@end
