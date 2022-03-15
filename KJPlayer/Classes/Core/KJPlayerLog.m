//
//  KJPlayerLog.m
//  KJPlayer
//
//  Created by yangkejun on 2021/9/16.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJPlayerLog.h"
#import "KJPlayerType.h"

@interface KJPlayerLog ()
/// 日志打印等级
@property(nonatomic,assign,class) KJPlayerVideoRankType rankType;

@end

@implementation KJPlayerLog

#pragma mark - log

static KJPlayerVideoRankType _rankType = KJPlayerVideoRankTypeNone;
+ (KJPlayerVideoRankType)rankType{
    return _rankType;
}
+ (void)setRankType:(KJPlayerVideoRankType)rankType{
    _rankType = rankType;
}
/// 打开几级日志打印，多枚举
+ (void)openLogRankType:(KJPlayerVideoRankType)type{
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

#pragma mark - error

/// 组建错误信息
/// @param code 错误编码
+ (NSError *)kj_errorWithCode:(NSInteger)code{
    NSString *userInfo = @"unknown";
    switch (code) {
        case KJPlayerCustomCodeCacheNone:
            userInfo = @"No cache data";
            break;
        case KJPlayerCustomCodeCachedComplete:
            userInfo = @"locality data";
            break;
        case KJPlayerCustomCodeSaveDatabase:
            userInfo = @"Succeed save database";
            break;
        case KJPlayerCustomCodeAVPlayerItemStatusUnknown:
            userInfo = @"Player item status unknown";
            break;
        case KJPlayerCustomCodeAVPlayerItemStatusFailed:
            userInfo = @"Player item status failed";
            break;
        case KJPlayerCustomCodeVideoURLUnknownFormat:
            userInfo = @"url unknown format";
            break;
        case KJPlayerCustomCodeVideoURLFault:
            userInfo = @"url fault";
            break;
        case KJPlayerCustomCodeWriteFileFailed:
            userInfo = @"write file failed";
            break;
        case KJPlayerCustomCodeReadCachedDataFailed:
            userInfo = @"Data read failed";
            break;
        case KJPlayerCustomCodeSaveDatabaseFailed:
            userInfo = @"Save database failed";
            break;
        case KJPlayerCustomCodeFinishLoading:
            userInfo = @"Resource loader cancelled";
            break;
        default:
            break;
    }
    return [NSError errorWithDomain:@"ykj.player" code:code userInfo:@{NSLocalizedDescriptionKey:userInfo}];
}

@end
