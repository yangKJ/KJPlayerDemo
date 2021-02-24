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
/* 子线程获取封面图，图片会存储在磁盘 */
@property (nonatomic,copy,readonly) void(^kVideoPlaceholderImage)(void(^)(UIImage *image),NSURL *,NSTimeInterval);

#pragma mark - NSNotification
/* 进入后台 */
- (void)kj_detectAppEnterBackground:(NSNotification*)notification;
/* 进入前台 */
- (void)kj_detectAppEnterForeground:(NSNotification*)notification;
/* KJBasePlayerView位置和尺寸发生变化，子类重写需调用父类 */
- (void)kj_basePlayerViewChange:(NSNotification*)notification;

@end

NS_ASSUME_NONNULL_END
