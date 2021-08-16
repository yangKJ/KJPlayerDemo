//
//  KJBasePlayer+KJTryTime.h
//  KJPlayer
//
//  Created by 77。 on 2021/8/16.
//  https://github.com/yangKJ/KJPlayerDemo
//  免费试看时间相关

#import "KJBasePlayer.h"

NS_ASSUME_NONNULL_BEGIN

/// 试看结束回调
typedef void(^_Nullable KJPlayerLookendBlock)(__kindof KJBasePlayer * player);

/// 免费试看时间相关
@interface KJBasePlayer (KJTryTime)

/// 免费试看时间和试看结束回调
/// @param time 试看时间，默认零不限制
/// @param lookend 试看结束回调
- (void)kj_tryLookTime:(NSTimeInterval)time lookend:(KJPlayerLookendBlock)lookend;

@end

NS_ASSUME_NONNULL_END
