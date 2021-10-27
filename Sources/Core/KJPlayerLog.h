//
//  KJPlayerLog.h
//  KJPlayer
//
//  Created by yangkejun on 2021/9/16.
//  https://github.com/yangKJ/KJPlayerDemo
//  日志管理类

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// 打印日志
#define PLAYERNSLog(type, frmt, ...) [KJPlayerLog kj_log:type format:frmt, ##__VA_ARGS__]
#define PLAYERLogInfo(frmt, ...)     PLAYERNSLog(KJPlayerVideoRankTypeAll,frmt, ##__VA_ARGS__)
#define PLAYERLogOneInfo(frmt, ...)  PLAYERNSLog(KJPlayerVideoRankTypeOne,frmt, ##__VA_ARGS__)
#define PLAYERLogTwoInfo(frmt, ...)  PLAYERNSLog(KJPlayerVideoRankTypeTwo,frmt, ##__VA_ARGS__)
/// 日志打印级别
typedef NS_OPTIONS(NSUInteger, KJPlayerVideoRankType) {
    KJPlayerVideoRankTypeNone = 1 << 0,/// 不打印
    KJPlayerVideoRankTypeOne  = 1 << 1,/// 一级，
    KJPlayerVideoRankTypeTwo  = 1 << 2,/// 二级
    
    KJPlayerVideoRankTypeAll = KJPlayerVideoRankTypeOne | KJPlayerVideoRankTypeTwo,
};
/// 日志管理类
@interface KJPlayerLog : NSObject

#pragma mark - log

/// 打开几级日志打印，仅需设置一次
/// @param type 日志等级，多枚举
+ (void)openLogRankType:(KJPlayerVideoRankType)type;

/// 按级别打印日志
/// @param type 日志等级，多枚举
/// @param format 打印标签
+ (void)kj_log:(KJPlayerVideoRankType)type format:(NSString *)format,...;

#pragma mark - error

/// 组建错误信息
/// @param code 错误编码
+ (NSError *)kj_errorWithCode:(NSInteger)code;

@end

NS_ASSUME_NONNULL_END
