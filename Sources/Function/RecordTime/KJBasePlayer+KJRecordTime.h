//
//  KJBasePlayer+KJRecordTime.h
//  KJPlayer
//
//  Created by 77。 on 2021/8/15.
//  https://github.com/yangKJ/KJPlayerDemo
//  记录播放时间相关

#import "KJBasePlayer.h"

NS_ASSUME_NONNULL_BEGIN

@protocol KJPlayerRecordDelegate;
/// 记录播放时间相关
@interface KJBasePlayer (KJRecordTime)

/// 记录播放时间协议，优先级高于跳过片头
@property (nonatomic, weak) id<KJPlayerRecordDelegate> recordDelegate;

/// 主动存储当前播放记录
- (void)kj_saveRecordLastTime;

@end

/// 记录播放时间协议
@protocol KJPlayerRecordDelegate <NSObject>

@optional;

/// 获取是否需要记录响应
/// @param player 播放器内核
- (BOOL)kj_recordTimeWithPlayer:(__kindof KJBasePlayer *)player;

/// 获取到上次播放时间响应
/// @param player 播放器内核
/// @param totalTime 总时长
/// @param lastTime 上次播放时间
- (void)kj_recordTimeWithPlayer:(__kindof KJBasePlayer *)player
                      totalTime:(NSTimeInterval)totalTime
                       lastTime:(NSTimeInterval)lastTime;

@end

NS_ASSUME_NONNULL_END
