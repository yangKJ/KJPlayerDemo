//
//  KJBasePlayer+KJSkipTime.m
//  KJPlayer
//
//  Created by 77。 on 2021/8/16.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJBasePlayer+KJSkipTime.h"

@interface KJBasePlayer ()

@property (nonatomic,assign) NSTimeInterval skipHeadTime;
@property (nonatomic,copy,readwrite) KJPlayerSkipStateBlock skipTimeBlock;

@end

@implementation KJBasePlayer (KJSkipTime)

- (BOOL)kj_skipTimePlayIMP{
    if (self.skipHeadTime) {
        if (self.skipTimeBlock) {
            kGCD_player_main(^{
                self.skipTimeBlock(self, KJPlayerVideoSkipStateHead);
            });
        }
        [self kj_appointTime:self.skipHeadTime];
        return YES;
    }
    return NO;
}

/// 跳过片头
/// @param headTime 片头
/// @param skipState 跳过状态回调
- (void)kj_skipHeadTime:(NSTimeInterval)headTime skipState:(KJPlayerSkipStateBlock)skipState{
    [self kj_skipHeadTime:headTime footTime:0 skipState:skipState];
}

/// 跳过片头和片尾回调，优先级低于记录上次播放时间
/// @param headTime 片头
/// @param footTime 片尾
/// @param skipState 跳过状态回调
- (void)kj_skipHeadTime:(NSTimeInterval)headTime
               footTime:(NSTimeInterval)footTime
              skipState:(KJPlayerSkipStateBlock)skipState{
    self.skipTimeBlock = skipState;
    self.skipHeadTime = headTime;
}

#pragma mark - Associated

- (KJPlayerSkipStateBlock)skipTimeBlock{
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setSkipTimeBlock:(KJPlayerSkipStateBlock)skipTimeBlock{
    objc_setAssociatedObject(self, @selector(skipTimeBlock), skipTimeBlock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
