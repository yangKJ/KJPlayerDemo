//
//  KJLogManager.h
//  KJPlayerDemo
//
//  Created by yangkejun on 2021/8/6.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo
//  日志工具管理器

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/// 日志打印级别
typedef NS_OPTIONS(NSUInteger, KJPlayerVideoRankType) {
    KJPlayerVideoRankTypeNone = 1 << 0,/// 不打印
    KJPlayerVideoRankTypeOne = 1 << 1, /// 一级，
    KJPlayerVideoRankTypeTwo = 1 << 2, /// 二级
    
    KJPlayerVideoRankTypeAll = KJPlayerVideoRankTypeOne | KJPlayerVideoRankTypeTwo,
};
/// 自定义错误情况
typedef NS_ENUM(NSInteger, KJPlayerCustomCode) {
    KJPlayerCustomCodeNormal = 0,/// 正常播放
    KJPlayerCustomCodeOtherSituations = 1,/// 其他情况
    KJPlayerCustomCodeCacheNone = 6,/// 没有缓存
    KJPlayerCustomCodeCachedComplete = 7,/// 缓存完成
    KJPlayerCustomCodeSaveDatabase = 8,/// 成功存入数据库
    KJPlayerCustomCodeFinishLoading = 96,/// 取消加载网络
    KJPlayerCustomCodeAVPlayerItemStatusUnknown = 97,/// playerItem状态未知
    KJPlayerCustomCodeAVPlayerItemStatusFailed = 98,/// playerItem状态出错
    KJPlayerCustomCodeVideoURLUnknownFormat = 99,/// 未知视频格式
    KJPlayerCustomCodeVideoURLFault = 100,/// 视频地址不正确
    KJPlayerCustomCodeWriteFileFailed = 101,/// 写入缓存文件错误
    KJPlayerCustomCodeReadCachedDataFailed = 102,/// 读取缓存数据错误
    KJPlayerCustomCodeSaveDatabaseFailed = 103,/// 存入数据库错误
};
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
