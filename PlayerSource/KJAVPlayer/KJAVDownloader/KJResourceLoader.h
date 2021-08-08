//
//  KJResourceLoader.h
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/9.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KJResourceLoader : NSObject <AVAssetResourceLoaderDelegate>
/// 返回时是否继续下载缓存 
@property (nonatomic, assign) BOOL backCancelLoading;
/// 当服务端返回的数据时调用
@property (nonatomic,copy,readwrite) void (^kDidReceiveData)(NSData * data);
/// 当请求错误的时候调用
@property (nonatomic,copy,readwrite) void (^kDidFinished)(KJResourceLoader * loader, NSError * error);

/// 设置特殊区分的链接地址 
- (NSURL * (^)(NSURL * URL))kj_createSchemeURL;

/// 取消网络请求 
- (void)kj_cancelLoading;

@end

NS_ASSUME_NONNULL_END
