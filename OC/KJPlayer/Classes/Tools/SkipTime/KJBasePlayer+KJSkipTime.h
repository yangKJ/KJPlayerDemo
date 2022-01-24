//
//  KJBasePlayer+KJSkipTime.h
//  KJPlayer
//
//  Created by 77。 on 2021/8/16.
//  https://github.com/yangKJ/KJPlayerDemo
//  跳过片头和片尾相关

#import "KJBasePlayer.h"

NS_ASSUME_NONNULL_BEGIN
/// 跳过播放
typedef NS_ENUM(NSUInteger, KJPlayerVideoSkipState) {
    KJPlayerVideoSkipStateHead, /// 跳过片头
    KJPlayerVideoSkipStateFoot, /// 跳过片尾
};
@protocol KJPlayerSkipDelegate;
/// 跳过片头和片尾相关
@interface KJBasePlayer (KJSkipTime)

/// 跳过片头片尾协议，优先级低于记录上次播放时间
@property (nonatomic, weak) id<KJPlayerSkipDelegate> skipDelegate;

@end

/// 跳过片头片尾协议，优先级低于记录上次播放时间
@protocol KJPlayerSkipDelegate <NSObject>

@optional;

/// 跳过片头时间设置响应
/// @param player 播放器内核
/// @return 返回片头时间
- (NSTimeInterval)kj_skipHeadTimeWithPlayer:(__kindof KJBasePlayer *)player;

/// 跳过片头时间设置响应
/// @param player 播放器内核
/// @return 返回片尾时间
- (NSTimeInterval)kj_skipFootTimeWithPlayer:(__kindof KJBasePlayer *)player;

/// 跳过响应
/// @param player 播放器内核
/// @param currentTime 当前播放时间
/// @param totalTime 总时长
/// @param skipState 跳过类型
- (void)kj_skipTimeWithPlayer:(__kindof KJBasePlayer *)player
                  currentTime:(NSTimeInterval)currentTime
                    totalTime:(NSTimeInterval)totalTime
                    skipState:(KJPlayerVideoSkipState)skipState;

@end

NS_ASSUME_NONNULL_END
