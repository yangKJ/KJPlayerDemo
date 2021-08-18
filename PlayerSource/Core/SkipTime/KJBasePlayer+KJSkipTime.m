//
//  KJBasePlayer+KJSkipTime.m
//  KJPlayer
//
//  Created by 77。 on 2021/8/16.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJBasePlayer+KJSkipTime.h"

@interface KJBasePlayer ()

@property (nonatomic,assign) NSTimeInterval skipHeadTime;
@property (nonatomic,assign) NSTimeInterval skipFootTime;

@end

@implementation KJBasePlayer (KJSkipTime)

- (BOOL)kj_skipTimePlayIMP{
    if (self.skipHeadTime) {
        if ([self.skipDelegate respondsToSelector:@selector(kj_skipTimeWithPlayer:currentTime:totalTime:skipState:)]) {
            PLAYER_WEAKSELF;
            kGCD_player_main(^{
                [weakself.skipDelegate kj_skipTimeWithPlayer:weakself
                                                 currentTime:weakself.skipHeadTime
                                                   totalTime:weakself.totalTime
                                                   skipState:KJPlayerVideoSkipStateHead];
            });
        }
        [self kj_appointTime:self.skipHeadTime];
        return YES;
    }
    return NO;
}

#pragma mark - Associated

- (id<KJPlayerSkipDelegate>)skipDelegate{
    return  objc_getAssociatedObject(self, _cmd);
}
- (void)setSkipDelegate:(id<KJPlayerSkipDelegate>)skipDelegate{
    objc_setAssociatedObject(self, @selector(skipDelegate), skipDelegate, OBJC_ASSOCIATION_ASSIGN);
    if ([skipDelegate respondsToSelector:@selector(kj_skipHeadTimeWithPlayer:)]) {
        self.skipHeadTime = [skipDelegate kj_skipHeadTimeWithPlayer:self];
    }
    if ([skipDelegate respondsToSelector:@selector(kj_skipFootTimeWithPlayer:)]) {
        self.skipFootTime = [skipDelegate kj_skipFootTimeWithPlayer:self];
    }
}

@end
