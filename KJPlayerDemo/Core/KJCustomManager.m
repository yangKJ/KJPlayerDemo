//
//  KJCustomManager.m
//  KJPlayerDemo
//
//  Created by yangkejun on 2021/8/6.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJCustomManager.h"

@interface KJCustomManager ()
/// 日志打印等级
@property(nonatomic,assign,class) KJPlayerVideoRankType rankType;
/// 正在下载的链接
@property(nonatomic,strong) NSMutableSet *downloadings;

@end

@implementation KJCustomManager

static KJCustomManager *_instance = nil;
static dispatch_once_t onceToken;
+ (instancetype)kj_sharedInstance{
    dispatch_once(&onceToken, ^{
        if (_instance == nil) {
            _instance = [[self alloc] init];
        }
    });
    return _instance;
}
- (NSMutableSet *)downloadings{
    if (!_downloadings) {
        _downloadings = [NSMutableSet set];
    }
    return _downloadings;
}

#pragma mark - 下载地址管理

- (void)kj_addDownloadURL:(NSURL*)url{
    @synchronized (self.downloadings) {
        [self.downloadings addObject:url];
    }
}
- (void)kj_removeDownloadURL:(NSURL*)url{
    @synchronized (self.downloadings) {
        [self.downloadings removeObject:url];
    }
}
- (BOOL)kj_containsDownloadURL:(NSURL*)url{
    @synchronized (self.downloadings) {
        return [self.downloadings containsObject:url];
    }
}

#pragma mark - 结构体相关

/// 缓存碎片结构体转对象
+ (NSValue *)kj_cacheFragment:(KJCacheFragment)fragment{
    return [NSValue valueWithBytes:&fragment objCType:@encode(struct KJCacheFragment)];
}
/// 缓存碎片对象转结构体
+ (KJCacheFragment)kj_getCacheFragment:(id)obj{
    KJCacheFragment fragment;
    [obj getValue:&fragment];
    return fragment;
}

#pragma mark - 错误提示汇总
/**网络错误相关，
 * 请求超时：-1001
 * 找不到服务器：-1003
 * 服务器内部错误：-1004
 * 网络中断：-1005
 * 无网络连接：-1009
 */
+ (NSError *)kj_errorSummarizing:(NSInteger)code{
    NSString *domain = @"unknown";
    NSDictionary *userInfo = nil;
    switch (code) {
        case KJPlayerCustomCodeCacheNone:
            domain = @"No cache data";
            break;
        case KJPlayerCustomCodeCachedComplete:
            domain = @"locality data";
            break;
        case KJPlayerCustomCodeSaveDatabase:
            domain = @"Succeed save database";
            break;
        case KJPlayerCustomCodeAVPlayerItemStatusUnknown:
            domain = @"Player item status unknown";
            break;
        case KJPlayerCustomCodeAVPlayerItemStatusFailed:
            domain = @"Player item status failed";
            break;
        case KJPlayerCustomCodeVideoURLUnknownFormat:
            domain = @"url unknown format";
            break;
        case KJPlayerCustomCodeVideoURLFault:
            domain = @"url fault";
            break;
        case KJPlayerCustomCodeWriteFileFailed:
            domain = @"write file failed";
            break;
        case KJPlayerCustomCodeReadCachedDataFailed:
            domain = @"Data read failed";
            break;
        case KJPlayerCustomCodeSaveDatabaseFailed:
            domain = @"Save database failed";
            break;
        case KJPlayerCustomCodeFinishLoading:
            domain = @"Resource loader cancelled";
            break;
        default:
            break;
    }
    return [NSError errorWithDomain:domain code:code userInfo:userInfo];
}

#pragma mark - 日志打印

static KJPlayerVideoRankType _rankType = KJPlayerVideoRankTypeNone;
+ (KJPlayerVideoRankType)rankType{
    return _rankType;
}
+ (void)setRankType:(KJPlayerVideoRankType)rankType{
    _rankType = rankType;
}
/// 打开几级日志打印，多枚举
+ (void)kj_openLogRankType:(KJPlayerVideoRankType)type{
    self.rankType = type;
}
/// 按级别打印日志
+ (void)kj_log:(KJPlayerVideoRankType)type format:(NSString *)format,...{
#ifdef DEBUG
    if (self.rankType == KJPlayerVideoRankTypeNone) {
        return;
    }
    va_list args;
    va_start(args, format);
    if (self.rankType == 1 || (self.rankType & KJPlayerVideoRankTypeOne)) {
        if (type == KJPlayerVideoRankTypeOne) {
            NSLogv([@"\n一级打印内容 " stringByAppendingString:format], args);
        }
        va_end(args);
        return;
    }
    if (self.rankType == 2 || (self.rankType & KJPlayerVideoRankTypeTwo)) {
        if (type == KJPlayerVideoRankTypeTwo) {
            NSLogv([@"\n二级打印内容 " stringByAppendingString:format], args);
        }
    }
    va_end(args);
#endif
}

@end
