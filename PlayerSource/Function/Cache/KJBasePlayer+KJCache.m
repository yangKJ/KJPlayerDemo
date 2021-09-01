//
//  KJBasePlayer+KJCache.m
//  KJPlayer
//
//  Created by 77。 on 2021/8/19.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJBasePlayer+KJCache.h"
#import "KJCacheManager.h"
#import "DBPlayerDataManager.h"

@interface KJBasePlayer ()
/// 错误信息
@property (nonatomic, strong) NSError * playError;
@property (nonatomic, assign) BOOL locality;
@property (nonatomic, assign) KJPlayerState state;

@end

@implementation KJBasePlayer (KJCache)

- (NSURL *)kj_cacheIMP:(NSURL *)videoURL{
    
    self.locality = [self kj_judgeHaveCacheWithVideoURL:&videoURL];
    
    return videoURL;
}

/// 桥接存储方法
/// @param object 错误信息
/// @param otherObject 主键ID
/// @param withBlock 插入信息回调
- (void)kj_saveCacheIMP:(NSError *)object otherObject:(id)otherObject withBlock:(void(^)(NSMutableDictionary *))withBlock{
    PLAYER_WEAKSELF;
    if (object.code == KJPlayerCustomCodeCachedComplete && !self.locality) {
        kGCD_player_async(^{
            if ([weakself kj_saveDatabaseVideoIntact:YES otherObject:otherObject withBlock:withBlock]) {
                kGCD_player_main(^{
                    weakself.playError = [KJLogManager kj_errorSummarizing:KJPlayerCustomCodeSaveDatabaseFailed];
                    weakself.state = KJPlayerStateFailed;
                });
            } else {
                @synchronized (@(weakself.locality)) {
                    weakself.locality = YES;
                }
            }
        });
    } else if (self.playError.code != object.code) {
        self.playError = object;
        kGCD_player_async(^{
            [weakself kj_saveDatabaseVideoIntact:NO otherObject:otherObject withBlock:withBlock];
        });
        self.state = KJPlayerStateFailed;
    }
}

/// 存储到本地数据库
/// @param videoIntact 视频是否完整
/// @param dbid 主键ID
/// @param withBlock 插入信息回调
- (BOOL)kj_saveDatabaseVideoIntact:(BOOL)videoIntact
                       otherObject:(NSString *)dbid
                         withBlock:(void(^)(NSMutableDictionary *))withBlock{
    NSError * error = nil;
    
    [DBPlayerDataManager kj_insertData:dbid insert:^(DBPlayerData * data){
        data.dbid = dbid;
        data.saveTime = NSDate.date.timeIntervalSince1970;
        data.videoIntact = videoIntact;
        NSMutableDictionary * __autoreleasing dict = [NSMutableDictionary dictionary];
        withBlock ? withBlock(dict) : nil;
        data.videoUrl = dict[@"videoUrl"];
        data.videoFormat = dict[@"videoFormat"];
        data.sandboxPath = [dbid stringByAppendingPathExtension:data.videoFormat];
        data.videoContentLength = [dict[@"videoContentLength"] longLongValue];
    } error:&error];
    if (error) {
        return YES;
    } else if (videoIntact) {
        kGCD_player_main(^{
            self.playError = [KJLogManager kj_errorSummarizing:KJPlayerCustomCodeSaveDatabase];
        });
    }
    return NO;
}

#pragma mark - public method

/// 判断是否为本地缓存视频，如果是则修改为指定链接地址
- (BOOL)kj_judgeHaveCacheWithVideoURL:(NSURL * _Nonnull __strong * _Nonnull)videoURL{
    if ([KJCacheManager kj_haveCacheURL:videoURL]) {
        self.playError = [KJLogManager kj_errorSummarizing:KJPlayerCustomCodeCachedComplete];
        return YES;
    }
    return NO;
}

@end
