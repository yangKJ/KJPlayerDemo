//
//  KJDownloaderCommon.m
//  KJPlayer
//
//  Created by 77。 on 2021/8/18.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJDownloaderCommon.h"
#import <CommonCrypto/CommonDigest.h>

/// 缓存相关信息通知
NSNotificationName const kPlayerFileHandleInfoNotification = @"kHomeRefreshRecentlyUseNotification";
/// 缓存相关信息接收key
NSNotificationName const kPlayerFileHandleInfoKey = @"kHomeAddRecentlyUseKey";

@interface KJDownloaderCommon ()
/// 正在下载的链接
@property(nonatomic,strong) NSMutableSet *downloadings;

@end

@implementation KJDownloaderCommon

static KJDownloaderCommon *_instance = nil;
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

NSString * kMD5FileNameFormVideoURL(NSURL * videoURL) {
    NSString * string = videoURL.resourceSpecifier ?: videoURL.absoluteString;
    const char * cstr = [string cStringUsingEncoding:NSUTF8StringEncoding];
    NSData * data = [NSData dataWithBytes:cstr length:string.length];
    uint8_t digest[CC_SHA512_DIGEST_LENGTH];
    CC_SHA512(data.bytes, (CC_LONG)data.length, digest);
    NSMutableString * output = [NSMutableString stringWithCapacity:CC_SHA512_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_SHA512_DIGEST_LENGTH; i++)
    [output appendFormat:@"%02x", digest[i]];
    return [NSString stringWithString:output];
}

@end
