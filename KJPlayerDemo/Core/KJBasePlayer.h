//
//  KJBasePlayer.h
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/10.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo
//  提取公共方法

#import <Foundation/Foundation.h>
#import "KJBaseFunctionPlayer.h"
#import "KJBaseUIPlayer.h"
#import "KJRotateManager.h"
#import "KJPlayerProtocol.h"
#import "DBPlayerDataInfo.h"
#import "KJCacheManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface KJBasePlayer : NSObject<KJBaseFunctionPlayer,KJBaseUIPlayer>
/* 单例属性 */
@property (nonatomic,strong,class,readonly,getter=kj_sharedInstance) id shared;
/* 创建单例 */
+ (instancetype)kj_sharedInstance;
/* 销毁单例 */
+ (void)kj_attempDealloc;
/* 主动存储当前播放记录 */
- (void)kj_saveRecordLastTime;
/* 动态切换播放内核 */
- (void)kj_dynamicChangeSourcePlayer:(Class)clazz;

#pragma mark - NSNotification
/* 进入后台 */
- (void)kj_detectAppEnterBackground:(NSNotification*)notification;
/* 进入前台 */
- (void)kj_detectAppEnterForeground:(NSNotification*)notification;

/* *********************  内部使用  *********************/
/* 是否进行过动态切换内核 */
@property (nonatomic,copy,readonly) BOOL (^kPlayerDynamicChangeSource)(void);
/* 当前播放器内核名 */
NSString * kPlayerCurrentSourceName(KJBasePlayer *bp);

@end

/// 公共属性区域
#define PLAYER_COMMON_EXTENSION_PROPERTY \
@property (nonatomic,copy,readwrite) void(^tryTimeBlock)(void);\
@property (nonatomic,copy,readwrite) void(^recordTimeBlock)(NSTimeInterval time);\
@property (nonatomic,copy,readwrite) void(^skipTimeBlock)(KJPlayerVideoSkipState skipState);\
@property (nonatomic,assign) NSTimeInterval tryTime;\
@property (nonatomic,assign) NSTimeInterval skipHeadTime;\
@property (nonatomic,assign) NSTimeInterval currentTime,totalTime;\
@property (nonatomic,assign) KJPlayerState state;\
@property (nonatomic,strong) NSError *playError;\
@property (nonatomic,assign) float progress;\
@property (nonatomic,assign) BOOL cache;\
@property (nonatomic,assign) BOOL tryLooked;\
@property (nonatomic,assign) BOOL recordLastTime;\
@property (nonatomic,assign) BOOL locality;\
@property (nonatomic,assign) BOOL userPause;\
@property (nonatomic,assign) BOOL isLiveStreaming;\
@property (nonatomic,strong) NSURL *originalURL;\
@property (nonatomic,retain) dispatch_group_t group;\
@property (nonatomic,assign) CGSize tempSize;\
@property (nonatomic,assign) BOOL buffered;\

/// 缓存相关公共区域
#define PLAYER_CACHE_COMMON_EXTENSION_PROPERTY \
@property (nonatomic,assign) KJPlayerState state;\
@property (nonatomic,strong) NSError *playError;\
@property (nonatomic,strong) NSURL *originalURL;\
@property (nonatomic,retain) dispatch_group_t group;\
@property (nonatomic,assign) float progress;\
@property (nonatomic,assign) BOOL cache;\
@property (nonatomic,assign) BOOL locality;\

NS_ASSUME_NONNULL_END
