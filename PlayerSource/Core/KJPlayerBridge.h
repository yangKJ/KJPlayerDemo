//
//  KJPlayerBridge.h
//  KJPlayer
//
//  Created by yangkejun on 2021/8/19.
//  https://github.com/yangKJ/KJPlayerDemo
//  播放器桥梁

#import <Foundation/Foundation.h>
#import "KJPlayerType.h"

NS_ASSUME_NONNULL_BEGIN
/// 不定参数回调方式
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wstrict-prototypes\"") \
typedef void(^KJPlayerAnyBlock)();
_Pragma("clang diagnostic pop")
@class KJBasePlayer;
/// 播放器桥梁，仅供内部使用
@interface KJPlayerBridge : NSObject
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new  UNAVAILABLE_ATTRIBUTE;

/// 初始化
/// @param basePlayer 当前内核
+ (instancetype)createBridgeWithBasePlayer:(__kindof KJBasePlayer *)basePlayer;

/// 万能参数
@property (nonatomic, strong) id anyObject;
@property (nonatomic, strong) id anyOtherObject;

/// 万能回调响应方法
/// @param index 协定使用
/// @param withBlock 回调响应
- (void)kj_anyArgumentsIndex:(NSInteger)index withBlock:(KJPlayerAnyBlock)withBlock;

#pragma mark - bridge method

/// 验证是否存在本地缓存
- (BOOL)kj_verifyCacheWithVideoURL;

/// 播放器状态改变
/// @param state 播放器状态
- (void)kj_changePlayerState:(KJPlayerState)state;

/// 开始播放时刻，准备功能处理
- (BOOL)kj_beginFunction;

/// 播放中，功能处理
/// @param time 当前播放时间
- (BOOL)kj_playingFunction:(NSTimeInterval)time;

/// 内核销毁时刻
- (void)kj_playerDealloc;

@end

NS_ASSUME_NONNULL_END
