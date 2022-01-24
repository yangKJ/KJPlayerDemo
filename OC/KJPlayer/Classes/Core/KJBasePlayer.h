//
//  KJBasePlayer.h
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/10.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo
//  提取公共方法

#import <Foundation/Foundation.h>
#import "KJPlayerFunction.h"
#import "KJPlayerProtocol.h"
#import "KJPlayerBridge.h"
#import "KJPlayerConst.h"
#import "KJPlayerLog.h"

NS_ASSUME_NONNULL_BEGIN

@class KJPlayerView;
@class KJPlayerDelegateManager;
/// 内核壳子，基类
@interface KJBasePlayer : NSObject <KJPlayerFunction>
/// 单例属性
@property (nonatomic,strong,class,readonly,getter=kj_sharedInstance) id shared;
/// 创建单例
+ (instancetype)kj_sharedInstance;
/// 销毁单例
+ (void)kj_attempDealloc;

/// 播放器桥接载体
@property (nonatomic,strong,readonly) KJPlayerBridge *bridge;

/// 播放器载体
@property (nonatomic,strong) __kindof KJPlayerView *playerView;
/// 占位图
@property (nonatomic,strong) UIImage *placeholder;
/// 背景颜色，默认黑色
@property (nonatomic,assign) CGColorRef background;
/// 视频显示模式，默认 KJPlayerVideoGravityResizeAspect
@property (nonatomic,assign) KJPlayerVideoGravity videoGravity;

@end

// UI公共ivar
#define PLAYER_COMMON_UI_PROPERTY \
@synthesize playerView = _playerView;\
@synthesize placeholder = _placeholder;\
@synthesize background = _background;\
@synthesize videoGravity = _videoGravity;\

NS_ASSUME_NONNULL_END
