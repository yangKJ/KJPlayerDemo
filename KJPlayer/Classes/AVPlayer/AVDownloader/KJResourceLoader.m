//
//  KJResourceLoader.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/9.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJResourceLoader.h"
#import "KJResourceLoaderManager.h"

#define kCustomVideoScheme @"__kj__player_header___"
@interface KJResourceLoader () <KJResourceLoaderManagerDelegate>
@property (nonatomic,strong) NSMutableDictionary<NSString*,KJResourceLoaderManager*>*loaderMap;

@end

@implementation KJResourceLoader

- (void)dealloc{
    if (self.backCancelLoading) {
        [self kj_cancelLoading];
    }
}
- (void)kj_cancelLoading{
    [self.loaderMap enumerateKeysAndObjectsUsingBlock:^(NSString * key, KJResourceLoaderManager * obj, BOOL * stop){
        [obj kj_cancelLoading];
    }];
    [self.loaderMap removeAllObjects];
}
- (NSURL * (^)(NSURL *))kj_createSchemeURL{
    return ^(NSURL * URL) {
        return [NSURL URLWithString:[kCustomVideoScheme stringByAppendingString:URL.absoluteString]];
    };
}
NS_INLINE NSString * kGetRequestKey(NSURL * requestURL){
    if ([[requestURL absoluteString] hasPrefix:kCustomVideoScheme]){
        return requestURL.absoluteString;
    }
    return nil;
}

#pragma mark - AVAssetResourceLoaderDelegate

/*  连接视频播放和视频断点下载的桥梁
 *  必须返回Yes，如果返回NO，则resourceLoader将会加载出现故障的数据
 *  这里会出现很多个loadingRequest请求,需要为每一次请求作出处理
 *  该接口会被调用多次，请求不同片段的视频数据，应当保存这些请求，在请求的数据全部响应完毕才销毁该请求
 *  @param resourceLoader 资源管理器
 *  @param loadingRequest 每一小块数据的请求
 */
- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader
shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest{
    NSString *key = kGetRequestKey(loadingRequest.request.URL);
    if (key == nil) return NO;
    KJResourceLoaderManager *manager = self.loaderMap[key];
    if (manager == nil){
        NSURL *resourceURL = loadingRequest.request.URL;
        NSString *string = [resourceURL.absoluteString stringByReplacingOccurrencesOfString:kCustomVideoScheme
                                                                                 withString:@""];
        NSURL *videoURL = [NSURL URLWithString:string];
        manager = [[KJResourceLoaderManager alloc] initWithVideoURL:videoURL];
        manager.delegate = self;
        self.loaderMap[key] = manager;
    }
    [manager kj_addRequest:loadingRequest];
    return YES;
}
/*  当视频播放器要取消请求时，相应的，也应该停止下载这部分数据。
 *  通常在拖拽视频进度时调这方法
 *  @param resourceLoader 资源管理器
 *  @param loadingRequest 每一小块数据的请求
 */
- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader
didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest{
    KJResourceLoaderManager *loader = self.loaderMap[kGetRequestKey(loadingRequest.request.URL)];
    [loader kj_removeRequest:loadingRequest];
}

#pragma mark - KJResourceLoaderManagerDelegate

/// 接收数据，是否为已经缓存的本地数据 
- (void)kj_resourceLoader:(KJResourceLoaderManager *)manager didReceiveData:(NSData *)data{
    if (self.kDidReceiveData) {
        self.kDidReceiveData(data);
    }
}
/// 接收错误或者接收完成，错误为空表示接收完成 
- (void)kj_resourceLoader:(KJResourceLoaderManager *)resourceLoader didFinished:(NSError *)error{
    [resourceLoader kj_cancelLoading];
    if (self.kDidFinished) {
        self.kDidFinished(self,error);
    }
}

#pragma mark - lazy

- (NSMutableDictionary<NSString *,KJResourceLoaderManager *> *)loaderMap{
    if (!_loaderMap) {
        _loaderMap = [NSMutableDictionary dictionary];
    }
    return _loaderMap;
}

@end
