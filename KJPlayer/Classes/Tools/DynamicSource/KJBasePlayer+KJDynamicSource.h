//
//  KJBasePlayer+KJDynamicSource.h
//  KJPlayer
//
//  Created by yangkejun on 2021/8/17.
//  https://github.com/yangKJ/KJPlayerDemo
//  动态切换内核相关

#import "KJBasePlayer.h"

NS_ASSUME_NONNULL_BEGIN

/// 动态切换内核相关
@interface KJBasePlayer (KJDynamicSource)

#pragma mark - 动态切换内核，TODO：待调试

/// 动态切换播放内核，核心就是切换isa
- (void)kj_dynamicChangeSourcePlayer:(Class)clazz;
/// 是否进行过动态切换内核
@property (nonatomic,copy,readonly) BOOL(^kPlayerDynamicChangeSource)(void);
/// 当前播放器内核名
@property (nonatomic,copy,readonly) NSString * (^kPlayerCurrentSourceName)(void);

@end

NS_ASSUME_NONNULL_END
