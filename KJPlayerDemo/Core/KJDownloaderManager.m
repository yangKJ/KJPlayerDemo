//
//  KJDownloaderManager.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/10.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJDownloaderManager.h"
@interface KJSessionAgent : NSObject<NSURLSessionDelegate>
@property (nonatomic,copy,readwrite) void (^kDidReceiveResponse)(NSURLResponse *response, void(^completionHandler)(NSURLSessionResponseDisposition));
@property (nonatomic,copy,readwrite) void (^kDidReceiveData)(NSData *data);
@property (nonatomic,copy,readwrite) void (^kDidFinished)(NSError *error);
@end

@interface KJDownloaderManager ()
@property (nonatomic,strong) KJSessionAgent *sessionAgent;
@property (nonatomic,strong) KJFileHandleManager *cacheManager;
@property (nonatomic,strong) NSMutableArray *fragments;
@property (nonatomic,strong) NSURLSession *session;
@property (nonatomic,strong) NSURLSessionDataTask *task;
@property (nonatomic,assign) NSInteger startOffset;
@property (nonatomic,strong) NSURL *videoURL;
@property (nonatomic,assign) BOOL cancelLoading;
@property (nonatomic,assign) BOOL once;
@end
@implementation KJDownloaderManager
- (void)dealloc{
    [self kj_cancelDownloading];
}
- (instancetype)initWithCachedFragments:(NSArray*)fragments videoURL:(NSURL*)url manager:(KJFileHandleManager*)manager{
    if (self = [super init]) {
        self.canSaveToCache = YES;
        self.fragments = [NSMutableArray arrayWithArray:fragments];
        self.cacheManager = manager;
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
- (void)kj_downlingFragment{
    if (self.cancelLoading) return;
    if (self.fragments.count == 0){
        /* warning - 此处别乱改要传nil出去，否则会出现播放不起的现象 */
        if ([self.delegate respondsToSelector:@selector(kj_didFinishWithError:)]){
            [self.delegate kj_didFinishWithError:nil];
        }
        return;
    }
    KJCacheFragment fragment = [DBPlayerDataInfo kj_getCacheFragment:self.fragments.firstObject];
    [self.fragments removeObjectAtIndex:0];
    if (fragment.type){// 远端碎片，即开始下载
        NSUInteger fromOffset = fragment.range.location;
        NSUInteger endOffset = fragment.range.location + fragment.range.length - 1;
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.videoURL];
        request.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
        NSString *range = [NSString stringWithFormat:@"bytes=%lu-%lu", fromOffset, endOffset];
        [request setValue:range forHTTPHeaderField:@"Range"];
        self.startOffset = fragment.range.location;
        self.task = [self.session dataTaskWithRequest:request];
        [self.task resume];
    }else{
        NSData *data = [self.cacheManager kj_readCachedDataWithRange:fragment.range];
        if (self.once == NO && data == nil) {
            self.once = YES;
            data = [self.cacheManager kj_readCachedDataWithRange:fragment.range];
        }
        if (data) {
            if ([self.delegate respondsToSelector:@selector(kj_didReceiveData:cached:)]) {
                [self.delegate kj_didReceiveData:data cached:YES];
            }
            [self kj_downlingFragment];
        }else{
            self.once = NO;
            if ([self.delegate respondsToSelector:@selector(kj_didFinishWithError:)]) {
                [self.delegate kj_didFinishWithError:[DBPlayerDataInfo kj_errorSummarizing:KJPlayerCustomCodeReadCachedDataFailed]];
            }
        }
    }
}

#pragma mark - lazy
- (NSURLSession*)session{
    if (!_session){
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self.sessionAgent delegateQueue:nil];
        _session = session;
    }
    return _session;
}
- (KJSessionAgent*)sessionAgent{
    if (!_sessionAgent){
        _sessionAgent = [[KJSessionAgent alloc] init];
        PLAYER_WEAKSELF;
        _sessionAgent.kDidReceiveResponse = ^(NSURLResponse *response, void (^completionHandler)(NSURLSessionResponseDisposition)) {
            NSString *mimeType = response.MIMEType;
            if ([mimeType rangeOfString:@"video/"].location == NSNotFound &&
                [mimeType rangeOfString:@"audio/"].location == NSNotFound &&
                [mimeType rangeOfString:@"application"].location == NSNotFound){
                completionHandler(NSURLSessionResponseCancel);
            }else{
                if ([weakself.delegate respondsToSelector:@selector(kj_didReceiveResponse:)]){
                    [weakself.delegate kj_didReceiveResponse:response];
                }
                [weakself.cacheManager kj_startWritting];
                completionHandler(NSURLSessionResponseAllow);
            }
        };
        _sessionAgent.kDidReceiveData = ^(NSData *data) {
            if (weakself.cancelLoading) return;
            if (weakself.canSaveToCache){
                NSRange range = NSMakeRange(weakself.startOffset, data.length);
                NSError *error;
                [weakself.cacheManager kj_writeCacheData:data Range:range error:&error];
                if (error) {
                    if ([weakself.delegate respondsToSelector:@selector(kj_didFinishWithError:)]) {
                        [weakself.delegate kj_didFinishWithError:error];
                    }
                    return;
                }
                [weakself.cacheManager kj_writeSave];
            }
            weakself.startOffset += data.length;
            if ([weakself.delegate respondsToSelector:@selector(kj_didReceiveData:cached:)]){
                [weakself.delegate kj_didReceiveData:data cached:NO];
            }
            kGCD_player_async(^{
                [weakself kj_postNotification];
            });
        };
        _sessionAgent.kDidFinished = ^(NSError *error) {
            [weakself.cacheManager kj_finishWritting];
            if (weakself.canSaveToCache){
                [weakself.cacheManager kj_writeSave];
            }
            if (weakself.cacheManager.cacheInfo.progress >= 1.0) {
                if ([weakself.delegate respondsToSelector:@selector(kj_didFinishWithError:)]){
                    [weakself.delegate kj_didFinishWithError:[NSError errorWithDomain:@"cache complete" code:KJPlayerCustomCodeCachedComplete userInfo:nil]];
                }
                return;
            }else{
                kGCD_player_async(^{
                    [weakself kj_postNotification];
                });
            }
            if (error){
                if ([weakself.delegate respondsToSelector:@selector(kj_didFinishWithError:)]){
                    [weakself.delegate kj_didFinishWithError:error];
                }
            }else{
                [weakself kj_downlingFragment];
            }
        };
    }
    return _sessionAgent;
}
- (void)kj_postNotification{
    [[NSNotificationCenter defaultCenter] postNotificationName:kPlayerFileHandleInfoNotification object:self userInfo:@{kPlayerFileHandleInfoKey:self.cacheManager.cacheInfo}];
}

@end

#pragma mark ------------------ NSURLSession的代理人 ------------------
@interface KJSessionAgent ()
/* 设置一个NSMutableData类型的对象, 用于接收返回的数据 */
@property (nonatomic,retain) NSMutableData *bufferData;
@end
@implementation KJSessionAgent
#pragma mark - NSURLSessionDataDelegate
- (void)URLSession:(NSURLSession*)session didReceiveChallenge:(NSURLAuthenticationChallenge*)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler{
    NSURLCredential *card = [[NSURLCredential alloc] initWithTrust:challenge.protectionSpace.serverTrust];
    completionHandler(NSURLSessionAuthChallengeUseCredential,card);
}
- (void)URLSession:(NSURLSession*)session
          dataTask:(NSURLSessionDataTask*)dataTask
didReceiveResponse:(NSURLResponse*)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler{
    self.bufferData = [NSMutableData data];
    if (self.kDidReceiveResponse) {
        self.kDidReceiveResponse(response,completionHandler);
    }
}
- (void)URLSession:(NSURLSession*)session dataTask:(NSURLSessionDataTask*)dataTask didReceiveData:(NSData*)data{
    @synchronized (self.bufferData){
        [self.bufferData appendData:data];
        if (self.bufferData.length >= 10*1024){// 10kb丢出去，开始播放
            NSRange chunkRange = NSMakeRange(0, self.bufferData.length);
            NSData *chunkData = [self.bufferData subdataWithRange:chunkRange];
            [self.bufferData replaceBytesInRange:chunkRange withBytes:NULL length:0];
            if (self.kDidReceiveData) {
                self.kDidReceiveData(chunkData);
            }
        }
    }
}
- (void)URLSession:(NSURLSession*)session task:(NSURLSessionDataTask*)task didCompleteWithError:(nullable NSError*)error{
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
