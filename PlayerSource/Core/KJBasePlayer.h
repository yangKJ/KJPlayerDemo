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
#import "KJPlayerProtocol.h"
#import "KJCustomManager.h"
#import "DBPlayerData.h"
#import "KJPlayerView.h"

NS_ASSUME_NONNULL_BEGIN

@interface KJBasePlayer : NSObject <KJBaseFunctionPlayer>
/// 单例属性
@property (nonatomic,strong,class,readonly,getter=kj_sharedInstance) id shared;
/// 创建单例
+ (instancetype)kj_sharedInstance;
/// 销毁单例
+ (void)kj_attempDealloc;

/// 播放器载体
@property (nonatomic,strong) __kindof KJPlayerView *playerView;
/// 占位图
@property (nonatomic,strong) UIImage *placeholder;
/// 背景颜色，默认黑色
@property (nonatomic,assign) CGColorRef background;
/// 视频显示模式，默认 KJPlayerVideoGravityResizeAspect
@property (nonatomic,assign) KJPlayerVideoGravity videoGravity;
/// 获取当前截屏
@property (nonatomic,copy,readonly) void (^kVideoTimeScreenshots)(void(^)(UIImage * image));
/// 子线程获取封面图，图片会存储在磁盘
@property (nonatomic,copy,readonly) void(^kVideoPlaceholderImage)(void(^)(UIImage * image), NSURL *, NSTimeInterval);

/// 判断是否为本地缓存视频，如果是则修改为指定链接地址
- (BOOL)kj_judgeHaveCacheWithVideoURL:(NSURL * _Nonnull __strong * _Nonnull)videoURL;

@end

NS_ASSUME_NONNULL_END
