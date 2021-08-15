//
//  KJBasePlayer+KJRecordTime.h
//  KJPlayer
//
//  Created by 77。 on 2021/8/15.
//  https://github.com/yangKJ/KJPlayerDemo
//  记录播放时间相关

#import "KJBasePlayer.h"

NS_ASSUME_NONNULL_BEGIN

@interface KJBasePlayer (KJRecordTime)
@property (nonatomic,assign) BOOL recordLastTime;
/// 获取记录上次观看时间
@property (nonatomic,copy,readonly) void (^kVideoRecordLastTime)(void(^)(NSTimeInterval time), BOOL record);

/// 主动存储当前播放记录
- (void)kj_saveRecordLastTime;

@end

NS_ASSUME_NONNULL_END
