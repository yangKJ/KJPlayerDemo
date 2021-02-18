//
//  KJDownloaderManager.h
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/10.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import <Foundation/Foundation.h>
#import "KJFileHandleManager.h"

NS_ASSUME_NONNULL_BEGIN

@protocol KJDownloaderManagerDelegate;
@interface KJDownloaderManager : NSObject
@property (nonatomic,weak) id<KJDownloaderManagerDelegate> delegate;
@property (nonatomic,assign) BOOL canSaveToCache;
/* 初始化 */
- (instancetype)initWithCachedFragments:(NSArray*)fragments videoURL:(NSURL*)url cacheManager:(KJFileHandleManager*)manager;
/* 开始下载，处理碎片 */
- (void)kj_startDownloading;
/* 取消下载 */
- (void)kj_cancelDownloading;

@end

@protocol KJDownloaderManagerDelegate <NSObject>
/* 开始接收数据，传递配置信息 */
- (void)kj_didReceiveResponse:(NSURLResponse*)response;
/* 接收数据，是否为已经缓存的本地数据 */
- (void)kj_didReceiveData:(NSData*)data cached:(BOOL)cached;
/* 接收错误或者接收完成 */
- (void)kj_didFinishWithError:(NSError *_Nullable)error;

@end


NS_ASSUME_NONNULL_END
