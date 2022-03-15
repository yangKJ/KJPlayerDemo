//
//  KJBasePlayer+KJCache.m
//  KJPlayer
//
//  Created by 77。 on 2021/8/19.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJBasePlayer+KJCache.h"
#import <objc/runtime.h>
#import "KJCacheManager.h"
#import "DBPlayerDataManager.h"

@interface KJBasePlayer ()
/// 错误信息
@property (nonatomic, strong) NSError * playError;
@property (nonatomic, assign) KJPlayerState state;
@property (nonatomic, assign) BOOL cache;
@property (nonatomic, assign) BOOL locality;

@end

@implementation KJBasePlayer (KJCache)

- (bool)kj_readLocalityIMP{
    return self.locality;
}
- (bool)kj_readCacheIMP{
    return self.cache;
}

/// 判断当前视频是否存在缓存
/// @param videoURL 视频链接地址
/// @return 存在会返回该缓存地址，不存在则返回原视频地址
- (NSURL *)kj_cacheIMP:(NSURL *)videoURL{
    if ([KJCacheManager kj_haveCacheURL:&videoURL]) {
        self.locality = YES;
        PLAYER_NOTIFICATION_CODE(self, @(KJPlayerCustomCodeCachedComplete));
    } else {
        self.locality = NO;
        PLAYER_NOTIFICATION_CODE(self, @(KJPlayerCustomCodeCacheNone));
    }
    if ([self.cacheDelegate respondsToSelector:@selector(kj_cacheWithPlayer:haveCache:cacheVideoURL:)]) {
        [self.cacheDelegate kj_cacheWithPlayer:self haveCache:self.locality cacheVideoURL:videoURL];
    }
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
            if ([weakself kj_saveVideoIntact:YES dbid:otherObject withBlock:withBlock]) {
                kGCD_player_main(^{
                    PLAYER_NOTIFICATION_CODE(weakself, @(KJPlayerCustomCodeSaveDatabaseFailed));
                    weakself.state = KJPlayerStateFailed;
                    if ([weakself.cacheDelegate respondsToSelector:@selector(kj_cacheWithPlayer:cacheSuccess:)]) {
                        [weakself.cacheDelegate kj_cacheWithPlayer:weakself cacheSuccess:NO];
                    }
                });
            } else {
                @synchronized (@(weakself.locality)) {
                    weakself.locality = YES;
                }
                kGCD_player_main(^{
                    if ([weakself.cacheDelegate respondsToSelector:@selector(kj_cacheWithPlayer:cacheSuccess:)]) {
                        [weakself.cacheDelegate kj_cacheWithPlayer:weakself cacheSuccess:YES];
                    }
                });
            }
        });
    } else if (self.playError.code != object.code) {
        self.playError = object;
        kGCD_player_async(^{
            [weakself kj_saveVideoIntact:NO dbid:otherObject withBlock:withBlock];
            if ([weakself.cacheDelegate respondsToSelector:@selector(kj_cacheWithPlayer:cacheSuccess:)]) {
                [weakself.cacheDelegate kj_cacheWithPlayer:weakself cacheSuccess:NO];
            }
        });
        self.state = KJPlayerStateFailed;
    }
}

/// 存储到本地数据库
/// @param videoIntact 视频是否完整
/// @param dbid 主键ID
/// @param withBlock 插入信息回调
- (BOOL)kj_saveVideoIntact:(BOOL)videoIntact dbid:(NSString *)dbid withBlock:(void(^)(NSMutableDictionary *))withBlock{
    NSError * error = nil;
    [DBPlayerDataManager kj_insertOrReplaceData:dbid insert:^(DBPlayerData * data){
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
        PLAYER_NOTIFICATION_CODE(self, @(KJPlayerCustomCodeSaveDatabase));
    }
    return NO;
}

#pragma mark - Associated

- (BOOL)cache{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}
- (void)setCache:(BOOL)cache{
    objc_setAssociatedObject(self, @selector(cache), @(cache), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)locality{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}
- (void)setLocality:(BOOL)locality{
    objc_setAssociatedObject(self, @selector(locality), @(locality), OBJC_ASSOCIATION_ASSIGN);
}

- (id<KJPlayerCacheDelegate>)cacheDelegate{
    return  objc_getAssociatedObject(self, _cmd);
}
- (void)setCacheDelegate:(id<KJPlayerCacheDelegate>)cacheDelegate{
    objc_setAssociatedObject(self, @selector(cacheDelegate), cacheDelegate, OBJC_ASSOCIATION_ASSIGN);
    if ([cacheDelegate respondsToSelector:@selector(kj_cacheWithPlayer:)]) {
        self.cache = [cacheDelegate kj_cacheWithPlayer:self];
    }
}

@end
