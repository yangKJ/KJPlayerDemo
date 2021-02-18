//
//  KJResourceLoaderManager.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/9.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJResourceLoaderManager.h"

@interface KJResourceLoaderManager ()
@property (nonatomic,strong, readwrite) NSURL *videoURL;
@property (nonatomic,strong) KJFileHandleManager *cacheManager;
@property (nonatomic,strong) KJDownloader *downloader;
@property (nonatomic,strong) NSMutableSet<AVAssetResourceLoadingRequest*>*requests;
@end

@implementation KJResourceLoaderManager
- (void)dealloc{
    [self.downloader kj_cancelDownload];
}
- (instancetype)initWithVideoURL:(NSURL*)url{
    self = [super init];
    if (self) {
        self.videoURL = url;
        self.cacheManager = [[KJFileHandleManager alloc] initWithURL:self.videoURL];
        self.downloader = [[KJDownloader alloc] initWithURL:self.videoURL cacheManager:self.cacheManager];
    }
    return self;
}
- (void)kj_addRequest:(AVAssetResourceLoadingRequest*)request{
    KJDownloader *downloader;
    if (self.requests.count){
        downloader = [[KJDownloader alloc]initWithURL:self.videoURL cacheManager:self.cacheManager];
    }else{
        downloader = self.downloader;
    }
    [self kj_addDownloader:downloader request:request];
}
- (void)kj_removeRequest:(AVAssetResourceLoadingRequest*)request{
    __block AVAssetResourceLoadingRequest *tempRequest = nil;
    [self.requests enumerateObjectsUsingBlock:^(AVAssetResourceLoadingRequest * _Nonnull obj, BOOL * _Nonnull stop) {
        if (request == obj) {
            tempRequest = obj;
            *stop = YES;
        }
    }];
    if (tempRequest) {
        if (tempRequest.isFinished == NO) {
            [tempRequest finishLoadingWithError:[DBPlayerDataInfo kj_errorSummarizing:KJPlayerCustomCodeFinishLoading]];
        }else{
            [tempRequest finishLoading];
        }
        [self.requests removeObject:tempRequest];
    }
}
- (void)kj_cancelLoading{
    [self.downloader kj_cancelDownload];
    [self.requests removeAllObjects];
    [DBPlayerDataInfo.shared kj_removeDownloadURL:self.videoURL];
}

#pragma mark - lazy
- (NSMutableSet<AVAssetResourceLoadingRequest *> *)requests{
    if (!_requests) {
        _requests = [NSMutableSet set];
    }
    return _requests;
}

#pragma mark - private method
/* 处理下载器数据 */
- (void)kj_addDownloader:(KJDownloader*)downloader request:(AVAssetResourceLoadingRequest*)request{
    kSetDownloadConfiguration(downloader, request);
    [self.requests addObject:request];
    [DBPlayerDataInfo.shared kj_addDownloadURL:self.videoURL];
    PLAYER_WEAKSELF;
    downloader.kDidReceiveResponse = ^(KJDownloader * downloader, NSURLResponse * response) {
        kSetDownloadConfiguration(downloader, request);
    };
    downloader.kDidReceiveData = ^(KJDownloader * downloader, NSData * data) {
        [request.dataRequest respondWithData:data];
    };
    downloader.kDidFinished = ^(KJDownloader * downloader, NSError * error) {
        if (error.code == NSURLErrorCancelled) return;
        if (error.code == KJPlayerCustomCodeCachedComplete) {
            [weakself kj_cancelLoading];
        }else if (error){
            [request finishLoadingWithError:error];
        }else{
            [request finishLoading];
            [weakself.requests removeObject:request];
        }
        if (weakself.requests.count == 0){
            [DBPlayerDataInfo.shared kj_removeDownloadURL:weakself.videoURL];
        }
        if ([weakself.delegate respondsToSelector:@selector(kj_resourceLoader:didFinished:)]){
            [weakself.delegate kj_resourceLoader:weakself didFinished:error];
        }
    };
    // 开始下载
    kStartDownloading(downloader, request);
}
/* 开始请求下载数据 */
NS_INLINE void kStartDownloading(KJDownloader *downloader, AVAssetResourceLoadingRequest *request){
    AVAssetResourceLoadingDataRequest *dataRequest = request.dataRequest;
    long long offset = dataRequest.requestedOffset;
    NSInteger length = dataRequest.requestedLength;
    if (dataRequest.currentOffset != 0) offset = dataRequest.currentOffset;
    if (@available(iOS 9.0, *)) {
        if (dataRequest.requestsAllDataToEndOfResource) {
            [downloader kj_downloadTaskRange:NSMakeRange((NSUInteger)offset, length) whole:YES];
            return;
        }
    }
    [downloader kj_downloadTaskRange:NSMakeRange((NSUInteger)offset, length) whole:NO];
}
/* 对请求加上长度，文件类型等信息，必须设置正确否则会报播放器Failed */
NS_INLINE void kSetDownloadConfiguration(KJDownloader *downloader,AVAssetResourceLoadingRequest *loadingRequest){
    AVAssetResourceLoadingContentInformationRequest *request = loadingRequest.contentInformationRequest;
    if (downloader.contentType) {
        request.contentType = downloader.contentType;
    }else{
        CFStringRef type = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef)(@"video/mp4"), NULL);
        request.contentType = CFBridgingRelease(type);
    }
    request.byteRangeAccessSupported = YES;
    request.contentLength = downloader.contentLength;
}

@end