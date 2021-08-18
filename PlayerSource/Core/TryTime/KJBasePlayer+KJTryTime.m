//
//  KJBasePlayer+KJTryTime.m
//  KJPlayer
//
//  Created by 77。 on 2021/8/16.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJBasePlayer+KJTryTime.h"

@interface KJBasePlayer ()

@property (nonatomic,assign) BOOL tryLooked;
@property (nonatomic,assign) NSTimeInterval tryTime;
@property (nonatomic,assign) NSTimeInterval currentTime;

@end

@implementation KJBasePlayer (KJTryTime)

- (BOOL)kj_tryTimePlayIMP:(id)object{
    /// 总时长为零时刻不处理试看
    if (self.totalTime == 0) {
        self.currentTime = 0;
        self.tryLooked = NO;
        return NO;
    }
    NSTimeInterval time = [object doubleValue];
    return [self kj_tryLook:time];
}

/// 试看处理
- (BOOL)kj_tryLook:(NSTimeInterval)time{
    PLAYER_WEAKSELF;
    if (self.tryTime && time >= self.tryTime) {
        self.currentTime = self.tryTime;
        if (self.tryLooked == NO) {
            self.tryLooked = YES;
            if ([self.tryLookDelegate respondsToSelector:@selector(kj_tryLookEndWithPlayer:currentTime:)]) {
                kGCD_player_main(^{
                    [weakself.tryLookDelegate kj_tryLookEndWithPlayer:weakself currentTime:time];
                });
            }
        }
    } else {
        self.currentTime = time;
        self.tryLooked = NO;
    }
    if ([self.tryLookDelegate respondsToSelector:@selector(kj_tryLookWithPlayer:tryTime:currentTime:lookEnd:)]) {
        kGCD_player_main(^{
            [weakself.tryLookDelegate kj_tryLookWithPlayer:weakself
                                                   tryTime:weakself.tryTime
                                               currentTime:weakself.currentTime
                                                   lookEnd:weakself.tryLooked];
        });
    }
    return self.tryLooked;
}

#pragma mark - Associated

- (id<KJPlayerTryLookDelegate>)tryLookDelegate{
    return  objc_getAssociatedObject(self, _cmd);
}
- (void)setTryLookDelegate:(id<KJPlayerTryLookDelegate>)tryLookDelegate{
    objc_setAssociatedObject(self, @selector(tryLookDelegate), tryLookDelegate, OBJC_ASSOCIATION_ASSIGN);
    if ([tryLookDelegate respondsToSelector:@selector(kj_tryLookTimeWithPlayer:)]) {
        self.tryTime = [tryLookDelegate kj_tryLookTimeWithPlayer:self];
    }
}

@end
