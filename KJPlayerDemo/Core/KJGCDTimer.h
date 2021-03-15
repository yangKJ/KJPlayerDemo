//
//  KJGCDTimer.h
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/23.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo
//  GCD计时器

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KJGCDTimer : NSObject
void kGCD_player_async(dispatch_block_t _Nonnull block);
void kGCD_player_main(dispatch_block_t _Nonnull block);

/* 创建定时器 */
+ (NSString *)kj_createTimerWithTask:(void(^)(void))task start:(NSTimeInterval)start interval:(NSTimeInterval)interval repeats:(BOOL)repeats async:(BOOL)async;
+ (NSString *)kj_createTimerWithTarget:(id)target selector:(SEL)selector start:(NSTimeInterval)start interval:(NSTimeInterval)interval repeats:(BOOL)repeats async:(BOOL)async;
/* 取消计时器 */
+ (void)kj_cancelTimer:(NSString *)name;
/* 暂停计时器 */
+ (void)kj_pauseTimer:(NSString *)name;
/* 继续计时器 */
+ (void)kj_resumeTimer:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
