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
#import "KJPlayerProtocol.h"
#import "KJCustomManager.h"
#import "DBPlayerData.h"

NS_ASSUME_NONNULL_BEGIN

@interface KJBasePlayer : NSObject <KJBaseFunctionPlayer,KJBaseUIPlayer>
/// 单例属性 
@property (nonatomic,strong,class,readonly,getter=kj_sharedInstance) id shared;
/// 创建单例 
+ (instancetype)kj_sharedInstance;
/// 销毁单例 
+ (void)kj_attempDealloc;

/// 主动存储当前播放记录 
- (void)kj_saveRecordLastTime;

#pragma mark - NSNotification
/// 进入后台 
- (void)kj_detectAppEnterBackground:(NSNotification*)notification;
/// 进入前台 
- (void)kj_detectAppEnterForeground:(NSNotification*)notification;

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
@property (nonatomic,assign) CGSize tempSize;\
@property (nonatomic,assign) float progress;\
@property (nonatomic,assign) BOOL buffered;\
@property (nonatomic,assign) BOOL cache;\
@property (nonatomic,assign) BOOL tryLooked;\
@property (nonatomic,assign) BOOL recordLastTime;\
@property (nonatomic,assign) BOOL locality;\
@property (nonatomic,assign) BOOL userPause;\
@property (nonatomic,assign) BOOL isLiveStreaming;\
@property (nonatomic,strong) NSURL *originalURL;\
@property (nonatomic,strong) dispatch_group_t group;\

/// 缓存相关公共区域
#define PLAYER_CACHE_COMMON_EXTENSION_PROPERTY \
@property (nonatomic,assign) KJPlayerState state;\
@property (nonatomic,strong) NSError *playError;\
@property (nonatomic,strong) NSURL *originalURL;\
@property (nonatomic,strong) dispatch_group_t group;\
@property (nonatomic,assign) float progress;\
@property (nonatomic,assign) BOOL cache;\
@property (nonatomic,assign) BOOL locality;\

NS_ASSUME_NONNULL_END
