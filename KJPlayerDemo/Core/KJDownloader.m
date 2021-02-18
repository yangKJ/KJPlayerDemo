//
//  KJDownloader.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/10.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJDownloader.h"
#import <objc/runtime.h>
@interface KJDownloader () <KJDownloaderManagerDelegate>
@property (nonatomic,strong) NSURL *videoURL;
@property (nonatomic,strong) KJFileHandleManager *cacheManager;
@property (nonatomic,strong) KJDownloaderManager *downloaderManager;
@property (nonatomic,assign) BOOL downloadWhole;
@end
@implementation KJDownloader
- (void)dealloc{
    [DBPlayerDataInfo.shared kj_removeDownloadURL:self.videoURL];
}
- (instancetype)initWithURL:(NSURL*)url cacheManager:(KJFileHandleManager*)manager{
    self = [super init];
    if (self) {
        self.saveToCache = YES;
        self.videoURL = url;
        self.cacheManager = manager;
        self.contentLength = manager.cacheInfo.contentLength;
        self.contentType = manager.cacheInfo.contentType;
        [DBPlayerDataInfo.shared kj_addDownloadURL:self.videoURL];
    }
    return self;
}
- (void)kj_createDownloaderManagerWithRange:(NSRange)range{
    NSArray *fragments = [self.cacheManager kj_dealwithCachedFragmentsWithRange:range];
    self.downloaderManager = [[KJDownloaderManager alloc] initWithCachedFragments:fragments videoURL:self.videoURL cacheManager:self.cacheManager];
    self.downloaderManager.canSaveToCache = self.saveToCache;
    self.downloaderManager.delegate = self;
    [self.downloaderManager kj_startDownloading];
}

- (void)kj_downloadTaskRange:(NSRange)range whole:(BOOL)whole{
    if (whole) range.length = self.contentLength - range.location;
    [self kj_createDownloaderManagerWithRange:range];
}
- (void)kj_startDownload{
    self.downloadWhole = YES;
    [self kj_createDownloaderManagerWithRange:NSMakeRange(0,2)];
}
- (void)kj_cancelDownload{
    self.downloaderManager.delegate = nil;
    [DBPlayerDataInfo.shared kj_removeDownloadURL:self.videoURL];
    [self.downloaderManager kj_cancelDownloading];
    self.downloaderManager = nil;
}

#pragma mark - KJDownloaderManagerDelegate
/* 开始接收数据，传递配置信息 */
- (void)kj_didReceiveResponse:(NSURLResponse*)response{
    if ([response isKindOfClass:[NSHTTPURLResponse class]]){
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
        NSArray *array = [httpResponse.allHeaderFields[@"Content-Range"] componentsSeparatedByString:@"/"];
        NSString *length = array.lastObject;
        if ([length integerValue] == 0){
            self.contentLength = (NSUInteger)httpResponse.expectedContentLength;
        }else{
            self.contentLength = [length integerValue];
        }
    }
    NSString *mimeType = response.MIMEType;
    CFStringRef contentType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef)(mimeType), NULL);
    self.contentType = CFBridgingRelease(contentType);
    [self.cacheManager kj_setContentLenght:self.contentLength contentType:self.contentType];
    if (self.kDidReceiveResponse) {
        self.kDidReceiveResponse(self, response);
    }
}
/* 接收数据，是否为已经缓存的本地数据 */
- (void)kj_didReceiveData:(NSData*)data cached:(BOOL)cached{
    if (self.kDidReceiveData) {
        self.kDidReceiveData(self, data);
    }
}
/* 接收错误或者接收完成，错误为空表示接收完成 */
- (void)kj_didFinishWithError:(NSError*_Nullable)error{
    [DBPlayerDataInfo.shared kj_removeDownloadURL:self.videoURL];
    if (error == nil && self.downloadWhole){
        self.downloadWhole = NO;
        [self kj_downloadTaskRange:NSMakeRange(2,self.contentLength-2) whole:YES];
    }
    if (self.kDidFinished) {
        self.kDidFinished(self, error);
    }
}

@end
@implementation KJDownloader (KJRequestBlock)
#pragma mark - Associated
- (void (^)(KJDownloader *, NSURLResponse *))kDidReceiveResponse{
    return objc_getAssociatedObject(self, _cmd);
}
- (void (^)(KJDownloader *, NSData *))kDidReceiveData{
    return objc_getAssociatedObject(self, _cmd);
}
- (void (^)(KJDownloader *, NSError *))kDidFinished{
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setKDidReceiveResponse:(void (^)(KJDownloader *, NSURLResponse *))kDidReceiveResponse{
    objc_setAssociatedObject(self, @selector(kDidReceiveResponse), kDidReceiveResponse, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (void)setKDidReceiveData:(void (^)(KJDownloader *, NSData *))kDidReceiveData{
    objc_setAssociatedObject(self, @selector(kDidReceiveData), kDidReceiveData, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (void)setKDidFinished:(void (^)(KJDownloader *, NSError *))kDidFinished{
    objc_setAssociatedObject(self, @selector(kDidFinished), kDidFinished, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end
