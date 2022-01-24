//
//  KJDownloader.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/10.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJDownloader.h"
#import <objc/runtime.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "KJDownloaderCommon.h"

@protocol KJDownloaderManagerDelegate;
@interface KJDownloadTask : NSObject
@property (nonatomic,weak) id<KJDownloaderManagerDelegate> delegate;
@property (nonatomic,assign) BOOL canSaveToCache;

/// 初始化
/// @param fragments 碎片信息组
/// @param url 链接地址
/// @param manager 文件管理器
- (instancetype)initWithCachedFragments:(NSArray *)fragments
                               videoURL:(NSURL *)url
                                manager:(KJFileHandleManager *)manager;
/// 开始下载，处理碎片 
- (void)kj_startDownloading;
/// 取消下载 
- (void)kj_cancelDownloading;

@end

@protocol KJDownloaderManagerDelegate <NSObject>

/// 开始接收数据，传递配置信息
/// @param response NSURLResponse
- (void)kj_didReceiveResponse:(NSURLResponse *)response;

/// 接收数据，是否为已经缓存的本地数据
/// @param data 下载数据
/// @param cached 是否成功缓存
- (void)kj_didReceiveData:(NSData *)data cached:(BOOL)cached;

/// 接收错误
/// @param error 错误数据，nil
- (void)kj_didFinishWithError:(nullable NSError *)error;

@end

// ************************************** 黄金分割线 *********************************************

@interface KJDownloader () <KJDownloaderManagerDelegate>
@property (nonatomic,strong) NSURL *videoURL;
@property (nonatomic,strong) NSString *contentType;
@property (nonatomic,assign) NSUInteger contentLength;
@property (nonatomic,strong) KJFileHandleManager *fileHandleManager;
@property (nonatomic,strong) KJDownloadTask *downloadTask;

@end

@implementation KJDownloader

- (void)dealloc{
    [KJDownloaderCommon.shared kj_removeDownloadURL:self.videoURL];
}
- (instancetype)initWithURL:(NSURL *)url{
    if (self = [super init]) {
        self.saveToCache = YES;
        self.videoURL = url;
        self.fileHandleManager = [[KJFileHandleManager alloc] initWithURL:url];
        self.contentLength = self.fileHandleManager.cacheInfo.contentLength;
        self.contentType = self.fileHandleManager.cacheInfo.contentType;
        [KJDownloaderCommon.shared kj_addDownloadURL:self.videoURL];
    }
    return self;
}
- (void)kj_createDownloaderManagerWithRange:(NSRange)range{
    NSArray *fragments = [self.fileHandleManager kj_getCachedFragmentsWithRange:range];
    self.downloadTask = [[KJDownloadTask alloc] initWithCachedFragments:fragments
                                                               videoURL:self.videoURL
                                                                manager:self.fileHandleManager];
    self.downloadTask.canSaveToCache = self.saveToCache;
    self.downloadTask.delegate = self;
    [self.downloadTask kj_startDownloading];
}

- (void)kj_downloadTaskRange:(NSRange)range whole:(BOOL)whole{
    if (whole) range.length = self.contentLength - range.location;
    [self kj_createDownloaderManagerWithRange:range];
}
- (void)kj_startDownload{
    [self kj_createDownloaderManagerWithRange:NSMakeRange(0,2)];
}
- (void)kj_cancelDownload{
    self.downloadTask.delegate = nil;
    [KJDownloaderCommon.shared kj_removeDownloadURL:self.videoURL];
    [self.downloadTask kj_cancelDownloading];
    self.downloadTask = nil;
}

#pragma mark - KJDownloaderManagerDelegate

/// 开始接收数据，传递配置信息 
- (void)kj_didReceiveResponse:(NSURLResponse *)response{
    if ([response isKindOfClass:[NSHTTPURLResponse class]]){
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSArray *array = [httpResponse.allHeaderFields[@"Content-Range"] componentsSeparatedByString:@"/"];
        NSString *length = array.lastObject;
        if ([length integerValue] == 0){
            self.contentLength = (NSUInteger)httpResponse.expectedContentLength;
        } else {
            self.contentLength = [length integerValue];
        }
    }
    CFStringRef contentType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef)(response.MIMEType), NULL);
    self.contentType = CFBridgingRelease(contentType);
    [self.fileHandleManager kj_setWriteHandleContentLenght:self.contentLength];
    self.fileHandleManager.cacheInfo.contentLength = self.contentLength;
    self.fileHandleManager.cacheInfo.contentType = self.contentType;
    if (self.kDidReceiveResponse) {
        self.kDidReceiveResponse(self, response);
    }
}
/// 接收数据，是否为已经缓存的本地数据 
- (void)kj_didReceiveData:(NSData *)data cached:(BOOL)cached{
    if (self.kDidReceiveData) {
        self.kDidReceiveData(self, data);
    }
}
/// 接收错误或者接收完成，错误为空表示接收完成 
- (void)kj_didFinishWithError:(NSError * _Nullable)error{
    [KJDownloaderCommon.shared kj_removeDownloadURL:self.videoURL];
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

// ************************************** 黄金分割线 *********************************************

@interface KJSessionAgent : NSObject <NSURLSessionDelegate>
@property (nonatomic,copy,readwrite) void (^kDidReceiveResponse)(NSURLResponse *response,
                                                                 void(^completionHandler)(NSURLSessionResponseDisposition));
@property (nonatomic,copy,readwrite) void (^kDidReceiveData)(NSData *data);
@property (nonatomic,copy,readwrite) void (^kDidFinished)(NSError *error);

@end

@interface KJDownloadTask ()
@property (nonatomic,strong) KJSessionAgent *sessionAgent;
@property (nonatomic,strong) KJFileHandleManager *fileHandleManager;
@property (nonatomic,strong) NSMutableArray *fragments;
@property (nonatomic,strong) NSURLSession *session;
@property (nonatomic,strong) NSURLSessionDataTask *task;
@property (nonatomic,assign) NSInteger startOffset;
@property (nonatomic,strong) NSURL *videoURL;
@property (nonatomic,assign) BOOL cancelLoading;
@property (nonatomic,assign) BOOL once;

@end

@implementation KJDownloadTask

- (void)dealloc{
    [self kj_cancelDownloading];
}
- (instancetype)initWithCachedFragments:(NSArray *)fragments
                               videoURL:(NSURL *)url
                                manager:(KJFileHandleManager *)manager{
    if (self = [super init]) {
        self.canSaveToCache = YES;
        self.fragments = [NSMutableArray arrayWithArray:fragments];
        self.fileHandleManager = manager;
        self.videoURL = url;
    }
    return self;
}
- (void)kj_startDownloading{
    self.once = NO;
    if (_session) [self.session invalidateAndCancel];
    [self kj_downlingFragment];
}
- (void)kj_cancelDownloading{
    if (_session) [self.session invalidateAndCancel];
    self.cancelLoading = YES;
    self.once = NO;
}
/// 下载分片数据 
- (void)kj_downlingFragment{
    if (self.cancelLoading) return;
    if (self.fragments.count == 0){
        /// 特别备注：此处别乱改要传nil出去，否则会出现播放不起的现象
        if ([self.delegate respondsToSelector:@selector(kj_didFinishWithError:)]){
            [self.delegate kj_didFinishWithError:nil];
        }
        return;
    }
    KJCacheFragment fragment = [KJFileHandleInfo kj_getCacheFragment:self.fragments.firstObject];
    [self.fragments removeObjectAtIndex:0];
    if (fragment.type){// 远端碎片，即开始下载
        unsigned long fromOffset = fragment.range.location;
        unsigned long endOffset  = fragment.range.location + fragment.range.length - 1;
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.videoURL];
        request.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
        NSString *range = [NSString stringWithFormat:@"bytes=%lu-%lu", fromOffset, endOffset];
        [request setValue:range forHTTPHeaderField:@"Range"];
        self.startOffset = fragment.range.location;
        self.task = [self.session dataTaskWithRequest:request];
        [self.task resume];
    } else {//本地碎片
        NSData * localData = [self.fileHandleManager kj_readCachedDataWithRange:fragment.range];
        if (self.once == NO && localData == nil) {
            self.once = YES;
            localData = [self.fileHandleManager kj_readCachedDataWithRange:fragment.range];
            if (localData == nil) {
                fragment.type = 1;
                unsigned long fromOffset = fragment.range.location;
                unsigned long endOffset  = fragment.range.location + fragment.range.length - 1;
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.videoURL];
                request.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
                NSString *range = [NSString stringWithFormat:@"bytes=%lu-%lu", fromOffset, endOffset];
                [request setValue:range forHTTPHeaderField:@"Range"];
                self.startOffset = fragment.range.location;
                self.task = [self.session dataTaskWithRequest:request];
                [self.task resume];
            }
        }
        if (localData) {
            if ([self.delegate respondsToSelector:@selector(kj_didReceiveData:cached:)]) {
                [self.delegate kj_didReceiveData:localData cached:YES];
            }
            [self kj_downlingFragment];
        } else {
            self.once = NO;
            if ([self.delegate respondsToSelector:@selector(kj_didFinishWithError:)]) {
                NSError * error = [NSError errorWithDomain:@"read cache data file"
                                                      code:KJDownloaderFailedCodeReadCachedDataFailed
                                                  userInfo:@{NSLocalizedDescriptionKey: @"read cache data file"}];
                [self.delegate kj_didFinishWithError:error];
            }
        }
    }
}

#pragma mark - lazy

- (NSURLSession *)session{
    if (!_session){
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration
                                                              delegate:self.sessionAgent
                                                         delegateQueue:nil];
        _session = session;
    }
    return _session;
}
- (KJSessionAgent *)sessionAgent{
    if (!_sessionAgent){
        _sessionAgent = [[KJSessionAgent alloc] init];
        __weak __typeof(self) weakself = self;
        _sessionAgent.kDidReceiveResponse = ^(NSURLResponse * response, void (^completionHandler)(NSURLSessionResponseDisposition)) {
            NSString *mimeType = response.MIMEType;
            if ([mimeType rangeOfString:@"video/"].location == NSNotFound &&
                [mimeType rangeOfString:@"audio/"].location == NSNotFound &&
                [mimeType rangeOfString:@"application"].location == NSNotFound){
                completionHandler(NSURLSessionResponseCancel);
            } else {
                if ([weakself.delegate respondsToSelector:@selector(kj_didReceiveResponse:)]) {
                    [weakself.delegate kj_didReceiveResponse:response];
                }
                [weakself.fileHandleManager kj_startWritting];
                completionHandler(NSURLSessionResponseAllow);
            }
        };
        _sessionAgent.kDidReceiveData = ^(NSData * data) {
            if (weakself.cancelLoading) return;
            if (weakself.canSaveToCache) {
                NSRange range = NSMakeRange(weakself.startOffset, data.length);
                NSError *error = [weakself.fileHandleManager kj_writeCacheData:data range:range];
                if (error) {
                    if ([weakself.delegate respondsToSelector:@selector(kj_didFinishWithError:)]) {
                        [weakself.delegate kj_didFinishWithError:error];
                    }
                    return;
                }
                [weakself.fileHandleManager kj_writeSave];
            }
            weakself.startOffset += data.length;
            if ([weakself.delegate respondsToSelector:@selector(kj_didReceiveData:cached:)]){
                [weakself.delegate kj_didReceiveData:data cached:NO];
            }
            if (weakself.fileHandleManager.cacheInfo) {
                NSDictionary * __autoreleasing userInfo = @{
                    kPlayerFileHandleInfoKey : weakself.fileHandleManager.cacheInfo
                };
                [[NSNotificationCenter defaultCenter] postNotificationName:kPlayerFileHandleInfoNotification
                                                                    object:weakself
                                                                  userInfo:userInfo];
            }
        };
        _sessionAgent.kDidFinished = ^(NSError * error) {
            [weakself.fileHandleManager kj_finishWritting];
            if (weakself.canSaveToCache){
                [weakself.fileHandleManager kj_writeSave];
            }
            if (weakself.fileHandleManager.cacheInfo.progress >= 1.0) {
                if ([weakself.delegate respondsToSelector:@selector(kj_didFinishWithError:)]){
                    NSError * error = [NSError errorWithDomain:@"cache complete"
                                                          code:KJDownloaderFailedCodeCachedSuccessful
                                                      userInfo:nil];
                    [weakself.delegate kj_didFinishWithError:error];
                }
                return;
            }
            if (error){
                if ([weakself.delegate respondsToSelector:@selector(kj_didFinishWithError:)]){
                    [weakself.delegate kj_didFinishWithError:error];
                }
            } else {
                [weakself kj_downlingFragment];
            }
        };
    }
    return _sessionAgent;
}

@end

#pragma mark - NSURLSession的代理人
@interface KJSessionAgent ()
/// 设置一个NSMutableData类型的对象, 用于接收返回的数据 
@property (nonatomic,retain) NSMutableData *bufferData;

@end

@implementation KJSessionAgent

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void(^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler{
    NSURLCredential *card = [[NSURLCredential alloc] initWithTrust:challenge.protectionSpace.serverTrust];
    completionHandler(NSURLSessionAuthChallengeUseCredential, card);
}
- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler{
    self.bufferData = [NSMutableData data];
    if (self.kDidReceiveResponse) {
        self.kDidReceiveResponse(response,completionHandler);
    }
}
- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data{
    @synchronized (self.bufferData){
        [self.bufferData appendData:data];
        if (self.bufferData.length >= 10 * 1024){// 10kb丢出去，开始播放
            NSRange chunkRange = NSMakeRange(0, self.bufferData.length);
            NSData *chunkData = [self.bufferData subdataWithRange:chunkRange];
            [self.bufferData replaceBytesInRange:chunkRange withBytes:NULL length:0];
            if (self.kDidReceiveData) {
                self.kDidReceiveData(chunkData);
            }
        }
    }
}
- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionDataTask *)task
didCompleteWithError:(nullable NSError *)error{
    @synchronized (self.bufferData){
        if (self.bufferData.length > 0 && error == nil){
            NSRange chunkRange = NSMakeRange(0, self.bufferData.length);
            NSData *chunkData = [self.bufferData subdataWithRange:chunkRange];
            [self.bufferData replaceBytesInRange:chunkRange withBytes:NULL length:0];
            if (self.kDidReceiveData) {
                self.kDidReceiveData(chunkData);
            }
        }
    }
    if (self.kDidFinished) {
        self.kDidFinished(error);
    }
}

@end
