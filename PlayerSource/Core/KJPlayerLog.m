//
//  KJPlayerLog.m
//  KJPlayer
//
//  Created by yangkejun on 2021/9/16.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJPlayerLog.h"

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
