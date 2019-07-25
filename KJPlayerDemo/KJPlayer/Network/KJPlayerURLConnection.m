//
//  KJPlayerURLConnection.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2019/7/20.
//  Copyright © 2019 杨科军. All rights reserved.
//

#import "KJPlayerURLConnection.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "KJRequestTask.h"
#import "KJPlayerTool.h"
///
NSString *const kMIMEType = @"video/mp4";

@interface KJPlayerURLConnection ()
@property (nonatomic,strong) NSMutableArray *loadingRequestTemps;
@property (nonatomic,strong) NSString *videoPath;
@property (nonatomic,strong) KJRequestTask *task;
@end

@implementation KJPlayerURLConnection
#pragma mark - init methods
- (instancetype)init{
    if (self == [super init]) {
        self.loadingRequestTemps = [NSMutableArray array];
        NSString *document = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
        self.videoPath = [document stringByAppendingPathComponent:@"videoTemp.mp4"];
    }
    return self;
}

#pragma mark - public methods
- (NSURL*)kSetComponentsWithUrl:(NSURL*)url{
    NSURLComponents *components = [[NSURLComponents alloc] initWithURL:url resolvingAgainstBaseURL:NO];
    components.scheme = @"streaming";
    return [components URL];
}

#pragma mark - privately methods
/// 对每次请求加上长度，文件类型等信息
- (void)kFillInContentInformation:(AVAssetResourceLoadingContentInformationRequest *)cRequest{
    /// 获取文件类型
    CFStringRef type = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef)(kMIMEType), NULL);
    cRequest.byteRangeAccessSupported = YES;
    cRequest.contentType = CFBridgingRelease(type);
    cRequest.contentLength = self.task.videoLength;
}
//在所有请求的数组中移除已经完成的
- (void)kProcessPendingRequests{
    /// 请求完成的数组
    NSMutableArray *temp = [NSMutableArray array];
    //1.每次下载一块数据都是一次请求，把这些请求放到数组，遍历数组
    [self.loadingRequestTemps enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        AVAssetResourceLoadingRequest *loadingRequest = (AVAssetResourceLoadingRequest*)obj;
        [self kFillInContentInformation:loadingRequest.contentInformationRequest];
        //2.判断此次请求的数据是否处理完全
        BOOL completely = [self kRespondDataWithRequest:loadingRequest.dataRequest];
        if (completely) {
            /// 如果完整，把此次请求放进 请求完成的数组
            [temp addObject:loadingRequest];
            [loadingRequest finishLoading];
            *stop = YES;
        }
    }];
    //在所有请求的数组中移除已经完成的
    [self.loadingRequestTemps removeObjectsInArray:temp];
}
/// 判断此次请求的数据是否处理完
- (BOOL)kRespondDataWithRequest:(AVAssetResourceLoadingDataRequest *)dataRequest{
    long long offset;
    if (dataRequest.currentOffset != 0) {
        /// 在资源中的下一个字节的资源中的位置，该位置位于先前通过调用-respondWithData提供的字节之后
        offset = dataRequest.currentOffset;
    }else{
        /// 请求的第一个字节在资源中的位置
        offset = dataRequest.requestedOffset;
    }
    
    /// 无数据下载
    if ((self.task.currentOffset + self.task.downLoadOffset) < offset || offset < self.task.currentOffset){
        return NO;
    }
    
    NSURL *url = [NSURL fileURLWithPath:_videoPath];
    NSData *fileData = [NSData dataWithContentsOfURL:url options:NSDataReadingMappedIfSafe error:nil];
    
    // 未播放的数据
    NSUInteger unreadBytes = self.task.downLoadOffset - ((NSInteger)offset - self.task.currentOffset);
    // 剩余的字节
    NSUInteger residueBytes = MIN((NSUInteger)dataRequest.requestedLength, unreadBytes);
    NSData *data = [fileData subdataWithRange:NSMakeRange((NSUInteger)offset - self.task.currentOffset, residueBytes)];
    /// 下载剩余数据
    [dataRequest respondWithData:data];
    
    long long endOffset = offset + dataRequest.requestedLength;
    BOOL complete = (self.task.currentOffset + self.task.downLoadOffset) >= endOffset;
    
    return complete;
}
/// 处理本次请求
- (void)dealWithLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest{
    NSURL *interceptedURL = [loadingRequest.request URL];
    NSRange range = NSMakeRange((NSUInteger)loadingRequest.dataRequest.currentOffset, NSUIntegerMax);
    
    if (self.task.downLoadOffset > 0) {
        [self kProcessPendingRequests];
    }
    
    if (!self.task) {
        self.task = [[KJRequestTask alloc] init];
        /// 回调事件处理
        [self kSetBlock];
        [self.task kj_startLoadWithUrl:interceptedURL Offset:0];
    } else {
        //1.如果新的rang的起始位置比当前缓存的位置还大300k，则重新按照range请求数据
        //2.如果往回拖也重新请求
        if (self.task.currentOffset + self.task.downLoadOffset + 1024 * 300 < range.location
            || range.location < self.task.currentOffset) {
            [self.task kj_startLoadWithUrl:interceptedURL Offset:range.location];
        }
    }
}
#pragma mark - AVAssetResourceLoaderDelegate
/** 连接视频播放和视频断点下载的桥梁
 *  必须返回Yes，如果返回NO，则resourceLoader将会加载出现故障的数据
 *  这里会出现很多个loadingRequest请求,需要为每一次请求作出处理
 *  该接口会被调用多次，请求不同片段的视频数据，应当保存这些请求，在请求的数据全部响应完毕才销毁该请求
 *  @param resourceLoader 资源管理器
 *  @param loadingRequest 每一小块数据的请求
 */
- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest{
    [self.loadingRequestTemps addObject:loadingRequest];
    [self dealWithLoadingRequest:loadingRequest];
//    NSLog(@"----%@", loadingRequest);
    return YES;
}
/** 当视频播放器要取消请求时，相应的，也应该停止下载这部分数据。
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
- (void)kSetBlock{
    PLAYER_WEAKSELF;
    //    self.task.kRequestTaskDidReceiveVideoLengthBlcok = ^(KJRequestTask * _Nonnull task, NSUInteger videoLength) {
    //
    //    };
    self.task.kRequestTaskDidReceiveDataBlcok = ^(KJRequestTask * _Nonnull task, NSData * _Nonnull data) {
        [weakself kProcessPendingRequests];
    };
    self.task.kRequestTaskDidFinishLoadingAndSaveFileBlcok = ^(KJRequestTask * _Nonnull task, BOOL saveSuccess) {
        if (weakself.kPlayerURLConnectionDidFinishLoadingAndSaveFileBlcok) {
            weakself.kPlayerURLConnectionDidFinishLoadingAndSaveFileBlcok(task.completeLoad,saveSuccess);
        }
    };
    self.task.kRequestTaskdidFailWithErrorCodeBlcok = ^(KJRequestTask * _Nonnull task, NSInteger errorCode) {
        if (weakself.kPlayerURLConnectiondidFailWithErrorCodeBlcok) {
            weakself.kPlayerURLConnectiondidFailWithErrorCodeBlcok(errorCode);
        }
    };
}

@end
