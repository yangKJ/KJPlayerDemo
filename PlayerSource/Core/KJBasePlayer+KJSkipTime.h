//
//  KJBasePlayer+KJSkipTime.h
//  KJPlayer
//
//  Created by 77。 on 2021/8/16.
//  https://github.com/yangKJ/KJPlayerDemo
//  跳过片头和片尾相关

#import "KJBasePlayer.h"

NS_ASSUME_NONNULL_BEGIN

/// 跳过状态回调
typedef void(^_Nullable KJPlayerSkipStateBlock)(__kindof KJBasePlayer * player, KJPlayerVideoSkipState skipState);

/// 跳过片头和片尾相关
@interface KJBasePlayer (KJSkipTime)

/// 跳过片头，优先级低于记录上次播放时间
/// 特别提醒：该方法必须在设置 `videoURL` 之前，否则无效
/// @param headTime 片头
/// @param skipState 跳过状态回调
- (void)kj_skipHeadTime:(NSTimeInterval)headTime skipState:(KJPlayerSkipStateBlock)skipState;

/// 跳过片头和片尾，优先级低于记录上次播放时间
/// 特别提醒：该方法必须在设置 `videoURL` 之前，否则无效
/// @param headTime 片头
/// @param footTime 片尾
/// @param skipState 跳过状态回调
- (void)kj_skipHeadTime:(NSTimeInterval)headTime
               footTime:(NSTimeInterval)footTime
              skipState:(KJPlayerSkipStateBlock)skipState;

@end

NS_ASSUME_NONNULL_END
