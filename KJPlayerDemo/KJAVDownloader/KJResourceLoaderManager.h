//
//  KJResourceLoaderManager.h
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/9.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol KJResourceLoaderManagerDelegate;
@interface KJResourceLoaderManager : NSObject
@property (nonatomic,strong,readonly) NSURL *videoURL;
@property (nonatomic,weak) id<KJResourceLoaderManagerDelegate> delegate;
- (instancetype)initWithVideoURL:(NSURL*)url;
/// 新增下载请求 
- (void)kj_addRequest:(AVAssetResourceLoadingRequest*)request;
/// 取消本次请求 
- (void)kj_removeRequest:(AVAssetResourceLoadingRequest*)request;
/// 取消所有请求加载 
- (void)kj_cancelLoading;

@end
@protocol KJResourceLoaderManagerDelegate <NSObject>
/// 接收数据，是否为已经缓存的本地数据 
- (void)kj_resourceLoader:(KJResourceLoaderManager*)manager didReceiveData:(NSData*)data;
/// 接收错误或者接收完成，错误为空表示接收完成 
- (void)kj_resourceLoader:(KJResourceLoaderManager*)manager didFinished:(NSError*)error;

@end

