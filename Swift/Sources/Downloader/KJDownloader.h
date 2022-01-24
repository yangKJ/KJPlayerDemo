//
//  KJDownloader.h
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/10.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import <Foundation/Foundation.h>
#import "KJFileHandleManager.h"

NS_ASSUME_NONNULL_BEGIN

/// 下载管理器
@interface KJDownloader : NSObject
/// 链接
@property (nonatomic,strong,readonly) NSURL *videoURL;
/// 写入和读取文件管理
@property (nonatomic,strong,readonly) KJFileHandleManager *fileHandleManager;
/// 是否缓存
@property (nonatomic,assign) BOOL saveToCache;

/// 初始化
/// @param url 链接
- (instancetype)initWithURL:(NSURL *)url;

/// 指定下载，是否下载到末尾全部数据
/// @param range 指定区间
/// @param whole 是否下载到末尾
- (void)kj_downloadTaskRange:(NSRange)range whole:(BOOL)whole;

/// 开始下载 
- (void)kj_startDownload;

/// 取消下载 
- (void)kj_cancelDownload;

@end

@interface KJDownloader (KJRequestBlock)
/// 当服务端开始接收数据时调用 
@property (nonatomic,copy,readwrite) void (^kDidReceiveResponse)(KJDownloader *downloader, NSURLResponse *response);
/// 当接收到数据的时候调用，该方法多次被调用返回接收到的服务端二进制数据 
@property (nonatomic,copy,readwrite) void (^kDidReceiveData)(KJDownloader *downloader, NSData *data);
/// 当请求错误的时候调用 
@property (nonatomic,copy,readwrite) void (^kDidFinished)(KJDownloader *downloader, NSError *error);

@end

NS_ASSUME_NONNULL_END
