//
//  KJAVPlayer+KJCache.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/10.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJAVPlayer+KJCache.h"
#import "KJResourceLoader.h"
#import "KJFileHandleInfo.h"
#import <objc/runtime.h>

@interface KJAVPlayer ()
PLAYER_CACHE_COMMON_EXTENSION_PROPERTY
@property (nonatomic,strong) KJResourceLoader *connection;
@property (nonatomic,strong) KJFileHandleInfo *cacheInfo;
@end
@implementation KJAVPlayer (KJCache)
/* 使用边播边缓存，m3u8暂不支持 */
- (BOOL (^)(NSURL * _Nonnull, BOOL))kVideoCanCacheURL{
    return ^BOOL(NSURL * videoURL, BOOL cache){
        kPlayerPerformSel(self, @"kj_initializeBeginPlayConfiguration");
        self.originalURL = videoURL;
        self.cache = cache;
        PLAYER_WEAKSELF;
        if (kPlayerVideoAesstType(videoURL) == KJPlayerAssetTypeNONE) {
            self.playError = [DBPlayerDataInfo kj_errorSummarizing:KJPlayerCustomCodeVideoURLUnknownFormat];
            if (self.player) [self kj_stop];
            return NO;
        }else if (kPlayerVideoAesstType(videoURL) == KJPlayerAssetTypeHLS) {
            dispatch_group_async(self.group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                kPlayerPerformSel(weakself, @"kj_initPreparePlayer");
            });
            return NO;
        }
        if (objc_getAssociatedObject(self, &connectionKey)) {
            objc_setAssociatedObject(self, &connectionKey, nil, OBJC_ASSOCIATION_RETAIN);
        }
        __block NSURL *tempURL = videoURL;
        dispatch_group_async(self.group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [weakself kj_judgeHaveCacheWithVideoURL:&tempURL];
            if (!kPlayerHaveTracks(tempURL, ^(AVURLAsset * asset) {
                if (weakself.cache && weakself.locality == NO) {
                    weakself.state = KJPlayerStateBuffering;
                    weakself.playError = [DBPlayerDataInfo kj_errorSummarizing:KJPlayerCustomCodeCacheNone];
                    NSURL * URL = weakself.connection.kj_createSchemeURL(tempURL);
                    weakself.asset = [AVURLAsset URLAssetWithURL:URL options:weakself.requestHeader];
                    [weakself.asset.resourceLoader setDelegate:weakself.connection queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
                }else{
                    weakself.asset = asset;
                }
            }, weakself.requestHeader)) {
                weakself.playError = [DBPlayerDataInfo kj_errorSummarizing:KJPlayerCustomCodeVideoURLFault];
                weakself.state = KJPlayerStateFailed;
                kPlayerPerformSel(weakself, @"kj_destroyPlayer");
            }else{
                kPlayerPerformSel(weakself, @"kj_initPreparePlayer");
            }
        });
        return YES;
    };
}

#pragma mark - associated
- (KJFileHandleInfo *)cacheInfo{
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setCacheInfo:(KJFileHandleInfo *)cacheInfo{
    objc_setAssociatedObject(self, @selector(cacheInfo), cacheInfo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
#pragma mark - lazy
static char connectionKey;
- (KJResourceLoader *)connection{
    KJResourceLoader *connection = objc_getAssociatedObject(self, &connectionKey);
    if (connection == nil) {
        connection = [[KJResourceLoader alloc] init];
        objc_setAssociatedObject(self, &connectionKey, connection, OBJC_ASSOCIATION_RETAIN);
        PLAYER_WEAKSELF;
        connection.kDidFinished = ^(KJResourceLoader *loader, NSError *error) {
            if (error == nil) return;
            [loader kj_cancelLoading];
            if (error.code == KJPlayerCustomCodeCachedComplete && !weakself.locality) {
                kGCD_player_async(^{
                    if ([weakself kj_saveDatabaseVideoIntact:YES]) {
                        if ([weakself kj_saveDatabaseVideoIntact:YES]) {
                            kGCD_player_main(^{
                                weakself.playError = [DBPlayerDataInfo kj_errorSummarizing:KJPlayerCustomCodeSaveDatabaseFailed];
                                weakself.state = KJPlayerStateFailed;
                            });
                        }
                    }else{
                        @synchronized (@(weakself.locality)) {
                            weakself.locality = YES;
                        }
                    }
                });
                return;
            }else if (weakself.playError.code != error.code) {
                weakself.playError = error;
                [weakself kj_saveDatabaseVideoIntact:NO];
                weakself.state = KJPlayerStateFailed;
            }
        };
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kj_playerCacheInfoChanged:) name:kPlayerFileHandleInfoNotification object:nil];
    }
    return connection;
}
//存储到本地数据库
- (BOOL)kj_saveDatabaseVideoIntact:(BOOL)videoIntact{
    PLAYER_WEAKSELF;
    NSError *__error;
    [DBPlayerDataInfo kj_insertData:self.cacheInfo.fileName Data:^(DBPlayerData * data){
        data.dbid = weakself.cacheInfo.fileName;
        data.videoUrl = weakself.cacheInfo.videoURL.absoluteString;
        data.videoFormat = weakself.cacheInfo.fileFormat;
        data.sandboxPath = [weakself.cacheInfo.fileName stringByAppendingPathExtension:weakself.cacheInfo.fileFormat];
        data.saveTime = NSDate.date.timeIntervalSince1970;
        data.videoIntact = videoIntact;
        data.videoContentLength = weakself.cacheInfo.contentLength;
    } error:&__error];
    if (__error) {
        return YES;
    }else if (videoIntact) {
        kGCD_player_main(^{
            weakself.playError = [DBPlayerDataInfo kj_errorSummarizing:KJPlayerCustomCodeSaveDatabase];
        });
    }
    return NO;
}

#pragma mark - notification
- (void)kj_playerCacheInfoChanged:(NSNotification*)notification{
    self.cacheInfo = notification.userInfo[kPlayerFileHandleInfoKey];
    PLAYER_WEAKSELF;
    kGCD_player_main(^{
        if (weakself.cache) weakself.progress = weakself.cacheInfo.progress;
    });
}

@end

