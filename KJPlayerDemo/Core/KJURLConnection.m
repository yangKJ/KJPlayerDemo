//
//  KJURLConnection.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2019/7/20.
//  Copyright © 2019 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJURLConnection.h"
#import <MobileCoreServices/MobileCoreServices.h>
NSString * const kMIMEType = @"video/mp4";
@interface KJURLConnection ()
@property (nonatomic,strong) NSMutableArray *loadingRequestTemps;
@property (nonatomic,strong) KJRequestTask *task;
@end
@implementation KJURLConnection
#pragma mark - init methods
- (instancetype)init{
    if (self == [super init]) {
        self.loadingRequestTemps = [NSMutableArray array];
    }
    return self;
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
- (void)kj_fillInContentInformation:(AVAssetResourceLoadingContentInformationRequest *)cRequest{
    CFStringRef type = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef)(kMIMEType), NULL);
    cRequest.byteRangeAccessSupported = YES;
    cRequest.contentType = CFBridgingRelease(type);
    cRequest.contentLength = self.task.totalOffset;
//    NSLog(@"-----%lu",(unsigned long)self.task.totalOffset/1024);
}
/// 在所有请求的数组中移除已经完成的
- (void)kj_processPendingRequests{
    NSMutableArray *temp = [NSMutableArray array];
    [self.loadingRequestTemps enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL * stop) {
        AVAssetResourceLoadingRequest *loadingRequest = (AVAssetResourceLoadingRequest*)obj;
        [self kj_fillInContentInformation:loadingRequest.contentInformationRequest];
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
    NSInteger offset;
    if (dataRequest.currentOffset != 0) {
        offset = dataRequest.currentOffset;
    }else{
        offset = dataRequest.requestedOffset;
    }
    if ((self.task.currentOffset + self.task.downLoadOffset) < offset ||
        offset < self.task.currentOffset) {
        return NO;
    }
    NSData *data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:PLAYER_TEMP_PATH] options:NSDataReadingMappedIfSafe error:nil];
    NSUInteger unreadBytes = self.task.downLoadOffset + self.task.currentOffset - offset;
    NSUInteger residueBytes = MIN((NSUInteger)dataRequest.requestedLength, unreadBytes);
    NSData *__data = [data subdataWithRange:NSMakeRange(offset - self.task.currentOffset, residueBytes)];
    [dataRequest respondWithData:__data];
    
    return (self.task.currentOffset + self.task.downLoadOffset) >= (offset+dataRequest.requestedLength);
}
/// 处理本次请求
- (void)kj_dealWithLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest{
    NSURL *interceptedURL = [loadingRequest.request URL];
    NSRange range = NSMakeRange(self.task.downLoadOffset, self.task.totalOffset);
    @synchronized (self.task) {
        if (!_task) {
            self.task = [[KJRequestTask alloc] init];
            [self kj_dealBlock];
            NSLog(@"--------%.2lu",(unsigned long)range.location);
            [self.task kj_startLoadWithUrl:interceptedURL Offset:range.location];
        }else{
            //1.如果新的rang的起始位置比当前缓存的位置还大300k，则重新按照range请求数据
            //2.如果往回拖也重新请求
            if (self.task.currentOffset + self.task.downLoadOffset + self.maxCacheRange < range.location ||
                range.location < self.task.currentOffset) {
                [self.task kj_startLoadWithUrl:interceptedURL Offset:range.location];
            }
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
/// 当视频播放器播放新的视频时，需要把之前发起的请求全部请求，并发起新的视频请求
- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForRenewalOfRequestedResource:(AVAssetResourceRenewalRequest *)renewalRequest{
    return YES;
}
#pragma mark - block
- (void)kj_dealBlock{
    PLAYER_WEAKSELF;
    self.task.kRequestTaskDidReceiveDataBlcok = ^(KJRequestTask * _Nonnull task, NSData * _Nonnull data) {
        [weakself kj_processPendingRequests];
    };
    self.task.kRequestTaskDidFinishLoadingAndSaveFileBlcok = ^(KJRequestTask * _Nonnull task, BOOL saveSuccess) {
        if (weakself.kURLConnectionDidFinishLoadingAndSaveFileBlcok) {
            weakself.kURLConnectionDidFinishLoadingAndSaveFileBlcok(saveSuccess);
        }
    };
    self.task.kRequestTaskdidFailWithErrorCodeBlcok = ^(KJRequestTask * _Nonnull task, NSInteger errorCode) {
        if (weakself.kURLConnectiondidFailWithErrorCodeBlcok) {
            weakself.kURLConnectiondidFailWithErrorCodeBlcok(errorCode);
        }
    };
}

@end
