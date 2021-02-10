//
//  KJResourceLoader.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2019/7/20.
//  Copyright © 2019 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJResourceLoader.h"
#import <MobileCoreServices/MobileCoreServices.h>
#define kCustomVideoScheme @"streaming"
@interface KJResourceLoader ()
@property (nonatomic,strong) NSMutableArray *loadingRequestTemps;
@property (nonatomic,strong) KJRequestTask *task;
@end
@implementation KJResourceLoader
#pragma mark - init methods
- (instancetype)init{
    if (self == [super init]) {
        self.loadingRequestTemps = [NSMutableArray array];
    }
    return self;
}
- (void)dealloc{
    if (self.task) {
        [self.task kj_clearTempLoadDatas];
    }
}
- (NSURL * (^)(NSURL *))kj_createSchemeURL{
    return ^(NSURL * URL){
        NSURLComponents *components = [[NSURLComponents alloc]initWithURL:URL resolvingAgainstBaseURL:NO];
        components.scheme = kCustomVideoScheme;
        return components.URL;
    };
}
#pragma mark - privately methods
/// 对每次请求加上长度，文件类型等信息
- (void)kj_appendingContentInformation:(AVAssetResourceLoadingContentInformationRequest *)request{
    CFStringRef type = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef)(KJPlayerVideoFromatMimeStringMap[self.videoFromat]), NULL);
    request.byteRangeAccessSupported = YES;
    request.contentType = CFBridgingRelease(type);
    request.contentLength = self.task.totalOffset;
}
/// 在所有请求的数组中移除已经完成的
- (void)kj_processPendingRequests{
    NSMutableArray *temp = [NSMutableArray array];
    [self.loadingRequestTemps enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL * stop) {
        AVAssetResourceLoadingRequest *loadingRequest = (AVAssetResourceLoadingRequest*)obj;
        [self kj_appendingContentInformation:loadingRequest.contentInformationRequest];
        if ([self kj_respondDataWithRequest:loadingRequest.dataRequest]) {
            [temp addObject:loadingRequest];
            [loadingRequest finishLoading];
            *stop = YES;
        }
    }];
    [self.loadingRequestTemps removeObjectsInArray:temp];
}
/// 判断此次请求的数据是否处理完
- (BOOL)kj_respondDataWithRequest:(AVAssetResourceLoadingDataRequest *)dataRequest{
    NSUInteger offset;
    if (dataRequest.currentOffset != 0) {
        offset = (NSUInteger)dataRequest.currentOffset;
    }else{
        offset = (NSUInteger)dataRequest.requestedOffset;
    }
    if ((self.task.currentOffset + self.task.downLoadOffset) < offset ||
        offset < self.task.currentOffset) {
        return NO;
    }
    NSData *data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:self.task.tempPath] options:NSDataReadingMappedIfSafe error:nil];
    NSUInteger unreadBytes = self.task.downLoadOffset + self.task.currentOffset - offset;
    NSUInteger residueBytes = MIN((NSUInteger)dataRequest.requestedLength, unreadBytes);
    NSData *__data = [data subdataWithRange:NSMakeRange(offset - self.task.currentOffset, residueBytes)];
    [dataRequest respondWithData:__data];
    
    return (self.task.currentOffset + self.task.downLoadOffset) >= (offset+dataRequest.requestedLength);
}
/// 处理本次请求
- (void)kj_dealWithLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest{
    NSURL *interceptedURL = [loadingRequest.request URL];
    if (!_task) {
        NSString *fromat = KJPlayerVideoFromatStringMap[self.videoFromat];
        self.task = [[KJRequestTask alloc] kj_initWithFlieFormat:fromat];
        self.task.fileName = kPlayerIntactName(interceptedURL);
        self.task.savePath = kPlayerIntactSandboxPath([self.task.fileName stringByAppendingString:fromat]);
        [self kj_dealBlock];
        [self.task kj_startLoadWithUrl:interceptedURL Offset:0];
    }else{
        //1.如果新的rang的起始位置比当前缓存的位置还大300k，则重新按照range请求数据
        //2.如果往回拖也重新请求
        NSRange range = NSMakeRange((NSUInteger)loadingRequest.dataRequest.currentOffset, NSUIntegerMax);
        if (self.task.currentOffset + self.task.downLoadOffset + self.maxCacheRange < range.location ||
            range.location < self.task.currentOffset) {
            [self.task kj_startLoadWithUrl:interceptedURL Offset:range.location];
        }
    }
}
#pragma mark - AVAssetResourceLoaderDelegate
/*  连接视频播放和视频断点下载的桥梁
 *  必须返回Yes，如果返回NO，则resourceLoader将会加载出现故障的数据
 *  这里会出现很多个loadingRequest请求,需要为每一次请求作出处理
 *  该接口会被调用多次，请求不同片段的视频数据，应当保存这些请求，在请求的数据全部响应完毕才销毁该请求
 *  @param resourceLoader 资源管理器
 *  @param loadingRequest 每一小块数据的请求
 */
- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest{
    [self.loadingRequestTemps addObject:loadingRequest];
    if (self.task.downLoadOffset > 0) [self kj_processPendingRequests];
    [self kj_dealWithLoadingRequest:loadingRequest];
    return YES;
}
/*  当视频播放器要取消请求时，相应的，也应该停止下载这部分数据。
 *  通常在拖拽视频进度时调这方法
 *  @param resourceLoader 资源管理器
 *  @param loadingRequest 每一小块数据的请求
 */
- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest{
    [self.loadingRequestTemps removeObject:loadingRequest];
}
/// 当视频播放器播放新的视频时，需要把之前发起的请求全部清楚，并发起新的视频请求
- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForRenewalOfRequestedResource:(AVAssetResourceRenewalRequest *)renewalRequest{
    [self.loadingRequestTemps removeAllObjects];
    return YES;
}
#pragma mark - block
- (void)kj_dealBlock{
    PLAYER_WEAKSELF;
    self.task.kRequestTaskReceiveDataBlcok = ^(KJRequestTask * _Nonnull task, NSData * _Nonnull data) {
        kGCD_player_main(^{
            if (weakself.kURLConnectionDidReceiveDataBlcok) {
                weakself.kURLConnectionDidReceiveDataBlcok(data, task.downLoadOffset, task.totalOffset);
            }
        });
        [weakself kj_processPendingRequests];
    };
    self.task.kRequestTaskSaveBlock = ^(KJRequestTask * _Nonnull task, BOOL saveSuccess) {
        if (weakself.kURLConnectionDidFinishLoadingAndSaveFileBlcok) {
            weakself.kURLConnectionDidFinishLoadingAndSaveFileBlcok(saveSuccess);
        }
    };
    self.task.kRequestTaskFailedBlcok = ^(KJRequestTask * _Nonnull task, NSInteger errorCode) {
        if (weakself.kURLConnectiondidFailWithErrorCodeBlcok) {
            weakself.kURLConnectiondidFailWithErrorCodeBlcok(errorCode);
        }
    };
}

@end
