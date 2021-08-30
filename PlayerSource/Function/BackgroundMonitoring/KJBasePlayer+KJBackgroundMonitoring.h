//
//  KJBasePlayer+KJBackgroundMonitoring.h
//  KJPlayer
//
//  Created by 77。 on 2021/8/29.
//  https://github.com/yangKJ/KJPlayerDemo
//  前后台功能相关

#import "KJBasePlayer.h"

NS_ASSUME_NONNULL_BEGIN

@interface KJBasePlayer (KJBackgroundMonitoring)

/// 返回前台继续播放，默认no
@property (nonatomic,assign) BOOL roregroundResume;
/// 进入后台暂停播放，默认no
@property (nonatomic,assign) BOOL backgroundPause;

@end

NS_ASSUME_NONNULL_END
