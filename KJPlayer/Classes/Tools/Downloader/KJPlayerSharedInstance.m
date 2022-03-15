//
//  KJPlayerSharedInstance.m
//  KJPlayer
//
//  Created by 77。 on 2021/8/18.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJPlayerSharedInstance.h"

@interface KJPlayerSharedInstance ()
/// 正在下载的链接
@property(nonatomic,strong) NSMutableSet *downloadings;

@end

@implementation KJPlayerSharedInstance

static KJPlayerSharedInstance *_instance = nil;
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

@end
