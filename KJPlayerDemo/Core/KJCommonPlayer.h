//
//  KJCommonPlayer.h
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/10.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo
//  提取公共方法

#import <Foundation/Foundation.h>
#import "KJBasePlayer.h"
NS_ASSUME_NONNULL_BEGIN

@interface KJCommonPlayer : NSObject<KJBasePlayer>
/* 单例属性 */
@property (nonatomic,strong,class,readonly,getter=kj_sharedInstance) id shared;
/* 创建单例 */
+ (instancetype)kj_sharedInstance;
/* 销毁单例 */
+ (void)kj_attempDealloc;
/* 进入后台 */
- (void)kj_playerAppDidEnterBackground:(NSNotification *)notification;
/* 进入前台 */
- (void)kj_playerAppWillEnterForeground:(NSNotification *)notification;

@end

NS_ASSUME_NONNULL_END
