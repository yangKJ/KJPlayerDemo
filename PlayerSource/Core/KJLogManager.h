//
//  KJLogManager.h
//  KJPlayerDemo
//
//  Created by yangkejun on 2021/8/6.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo
//  日志工具管理器

#import <Foundation/Foundation.h>
#import "KJPlayerType.h"

NS_ASSUME_NONNULL_BEGIN
/// 打印日志
#define PLAYERNSLog(type, frmt, ...) [KJLogManager kj_log:type format:frmt, ##__VA_ARGS__]
#define PLAYERLogInfo(frmt, ...)     PLAYERNSLog(KJPlayerVideoRankTypeAll,frmt, ##__VA_ARGS__)
#define PLAYERLogOneInfo(frmt, ...)  PLAYERNSLog(KJPlayerVideoRankTypeOne,frmt, ##__VA_ARGS__)
#define PLAYERLogTwoInfo(frmt, ...)  PLAYERNSLog(KJPlayerVideoRankTypeTwo,frmt, ##__VA_ARGS__)

@interface KJLogManager : NSObject

#pragma mark - 错误提示汇总

/// 创建指定错误
+ (NSError *)kj_errorSummarizing:(NSInteger)code;

#pragma mark - 日志打印

/// 打开几级日志打印，仅需设置一次
/// @param type 日志等级，多枚举
+ (void)kj_openLogRankType:(KJPlayerVideoRankType)type;

/// 按级别打印日志
/// @param type 日志等级，多枚举
/// @param format 打印标签
+ (void)kj_log:(KJPlayerVideoRankType)type format:(NSString *)format,...;

@end

NS_ASSUME_NONNULL_END
