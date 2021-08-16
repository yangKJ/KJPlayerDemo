//
//  KJBasePlayer+KJRecordTime.h
//  KJPlayer
//
//  Created by 77。 on 2021/8/15.
//  https://github.com/yangKJ/KJPlayerDemo
//  记录播放时间相关

#import "KJBasePlayer.h"

NS_ASSUME_NONNULL_BEGIN

/// 记录播放时间相关
@interface KJBasePlayer (KJRecordTime)

/// 获取记录上次观看时间
/// @param record 是否需要记录观看时间
/// @param lastTime 上次播放时间回调
- (void)kj_videoRecord:(BOOL)record lastTime:(void(^)(NSTimeInterval time))lastTime;
/// 主动存储当前播放记录
- (void)kj_saveRecordLastTime;

@end

NS_ASSUME_NONNULL_END
