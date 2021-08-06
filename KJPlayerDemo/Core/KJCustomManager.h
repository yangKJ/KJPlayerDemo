//
//  KJCustomManager.h
//  KJPlayerDemo
//
//  Created by yangkejun on 2021/8/6.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo
//  公共工具管理器，单例存在

#import <Foundation/Foundation.h>
#import "KJPlayerType.h"

NS_ASSUME_NONNULL_BEGIN

@interface KJCustomManager : NSObject
/// 单例属性
@property (nonatomic,strong,class,readonly,getter=kj_sharedInstance) KJCustomManager *shared;

/// 正在下载的请求
@property (nonatomic,strong,readonly) NSMutableSet * downloadings;

#pragma mark - 下载地址管理
/// 新增网址
- (void)kj_addDownloadURL:(NSURL *)url;
/// 移出网址
- (void)kj_removeDownloadURL:(NSURL *)url;
/// 是否包含网址
- (BOOL)kj_containsDownloadURL:(NSURL *)url;

#pragma mark - 结构体相关
/// 缓存碎片结构体转对象
+ (NSValue *)kj_cacheFragment:(KJCacheFragment)fragment;
/// 缓存碎片对象转结构体
+ (KJCacheFragment)kj_getCacheFragment:(id)obj;

#pragma mark - 错误提示汇总
/// 创建指定错误
+ (NSError*)kj_errorSummarizing:(NSInteger)code;

#pragma mark - 日志打印
/// 打印日志
#define PLAYERNSLog(type, frmt, ...) [KJCustomManager kj_log:type format:frmt, ##__VA_ARGS__]
#define PLAYERLogInfo(frmt, ...)     PLAYERNSLog(KJPlayerVideoRankTypeAll,frmt, ##__VA_ARGS__)
#define PLAYERLogOneInfo(frmt, ...)  PLAYERNSLog(KJPlayerVideoRankTypeOne,frmt, ##__VA_ARGS__)
#define PLAYERLogTwoInfo(frmt, ...)  PLAYERNSLog(KJPlayerVideoRankTypeTwo,frmt, ##__VA_ARGS__)
/// 打开几级日志打印，多枚举
+ (void)kj_openLogRankType:(KJPlayerVideoRankType)type;
/// 按级别打印日志
+ (void)kj_log:(KJPlayerVideoRankType)type format:(NSString *)format,...;

@end

NS_ASSUME_NONNULL_END
