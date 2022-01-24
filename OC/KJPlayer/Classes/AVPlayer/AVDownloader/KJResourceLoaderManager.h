//
//  KJResourceLoaderManager.h
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/9.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class KJResourceLoaderManager;
@protocol KJResourceLoaderManagerDelegate <NSObject>

@required;

/// 接收数据，是否为已经缓存的本地数据
/// @param manager manager
/// @param data 接收数据
- (void)kj_resourceLoader:(KJResourceLoaderManager *)manager didReceiveData:(NSData *)data;

/// 接收错误或者接收完成，错误为空表示接收完成
/// @param manager manager
/// @param error 错误信息
- (void)kj_resourceLoader:(KJResourceLoaderManager *)manager didFinished:(NSError *)error;

@end

@class AVAssetResourceLoadingRequest;
@interface KJResourceLoaderManager : NSObject
/// 视频地址
@property (nonatomic,strong,readonly) NSURL *videoURL;
/// 委托协议
@property (nonatomic,weak) id<KJResourceLoaderManagerDelegate> delegate;

/// 初始化
/// @param url 视频地址
- (instancetype)initWithVideoURL:(NSURL *)url;

/// 新增下载请求
/// @param request 请求头
- (void)kj_addRequest:(AVAssetResourceLoadingRequest *)request;

/// 取消本次请求
/// @param request 请求头
- (void)kj_removeRequest:(AVAssetResourceLoadingRequest *)request;

/// 取消所有请求加载 
- (void)kj_cancelLoading;

@end

NS_ASSUME_NONNULL_END
