//
//  KJPlayer+KJCache.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/10.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJPlayer+KJCache.h"
#import "KJResourceLoader.h"
#import "KJFileHandleInfo.h"
#import <objc/runtime.h>

@interface KJPlayer ()
@property (nonatomic,assign) KJPlayerVideoFromat fromat;
@property (nonatomic,strong) KJResourceLoader *connection;
@property (nonatomic,assign) KJPlayerState state;
@property (nonatomic,strong) KJFileHandleInfo *cacheInfo;
@property (nonatomic,strong) NSURL *originalURL;
@property (nonatomic,retain) dispatch_group_t group;
@property (nonatomic,assign) float progress;
@property (nonatomic,assign) BOOL cache;
@property (nonatomic,assign) BOOL locality;
@end
@implementation KJPlayer (KJCache)
/* 判断当前资源文件是否有缓存，修改为指定链接地址 */
- (void)kj_judgeHaveCacheWithVideoURL:(NSURL * _Nonnull __strong * _Nonnull)videoURL{
    self.locality = NO;
    self.asset = nil;
    KJCachePlayerManager.kJudgeHaveCacheURL(^(BOOL locality) {
        self.locality = locality;
        if (locality) {
            self.playError = [DBPlayerDataInfo kj_errorSummarizing:KJPlayerCustomCodeCachedComplete];
        }
    }, videoURL);
}
/* 使用边播边缓存，m3u8暂不支持 */
- (BOOL (^)(NSURL * _Nonnull, BOOL))kVideoCanCacheURL{
    return ^BOOL(NSURL * videoURL, BOOL cache){
        self.originalURL = videoURL;
        self.fromat = kPlayerFromat(videoURL);
        if (self.kVideoURLFromat) self.kVideoURLFromat(self.fromat);
        PLAYER_WEAKSELF;
        if (self.fromat == KJPlayerVideoFromat_m3u8) {
            self.locality = NO;
            self.asset = nil;
            dispatch_group_async(weakself.group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [weakself kj_performSelString:@"kj_initPreparePlayer"];
            });
            return NO;
        }
        if (objc_getAssociatedObject(self, &connectionKey)) {
            objc_setAssociatedObject(self, &connectionKey, nil, OBJC_ASSOCIATION_RETAIN);
        }
        self.cache = cache;
        __block NSURL *tempURL = videoURL;
        dispatch_group_async(self.group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [weakself kj_judgeHaveCacheWithVideoURL:&tempURL];
            if (!kPlayerHaveTracks(tempURL, ^(AVURLAsset * asset) {
                if (weakself.cache && weakself.locality == NO) {
                    weakself.state = KJPlayerStateBuffering;
                    weakself.playError = [DBPlayerDataInfo kj_errorSummarizing:KJPlayerCustomCodeCacheNone];
                    NSURL * URL = weakself.connection.kj_createSchemeURL(tempURL);
                    weakself.asset = [AVURLAsset URLAssetWithURL:URL options:weakself.requestHeader];
                    [weakself.asset.resourceLoader setDelegate:weakself.connection queue:dispatch_get_main_queue()];
                }else{
                    weakself.asset = asset;
                }
            }, weakself.requestHeader)) {
                weakself.playError = [DBPlayerDataInfo kj_errorSummarizing:KJPlayerCustomCodeVideoURLFault];
                weakself.state = KJPlayerStateFailed;
                [weakself kj_performSelString:@"kj_destroyPlayer"];
            }else{
                [weakself kj_performSelString:@"kj_initPreparePlayer"];
            }
        });
        return YES;
    };
}

#pragma mark - private method
// 隐式调用
- (void)kj_performSelString:(NSString*)name{
    SEL sel = NSSelectorFromString(name);
    if ([self respondsToSelector:sel]) {
        ((void(*)(id, SEL))(void*)objc_msgSend)((id)self, sel);
    }
}
// 判断是否含有视频轨道
NS_INLINE BOOL kPlayerHaveTracks(NSURL *videoURL, void(^assetblock)(AVURLAsset *), NSDictionary *requestHeader){
    if (videoURL == nil) return NO;
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:videoURL options:requestHeader];
    if (assetblock) assetblock(asset);
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    return [tracks count] > 0;
}

#pragma mark - associated
- (BOOL)locality{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}
- (void)setLocality:(BOOL)locality{
    objc_setAssociatedObject(self, @selector(locality), @(locality), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (AVURLAsset *)asset{
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setAsset:(AVURLAsset *)asset{
    objc_setAssociatedObject(self, @selector(asset), asset, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
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

