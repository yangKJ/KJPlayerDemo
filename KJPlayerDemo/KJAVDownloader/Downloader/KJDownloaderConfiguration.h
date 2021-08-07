//
//  KJDownloaderConfiguration.h
//  KJPlayer
//
//  Created by yangkejun on 2021/8/7.
//  https://github.com/yangKJ/KJPlayerDemo
//  下载器单例，

#import <Foundation/Foundation.h>
#import "KJPlayerType.h"
#import "KJCustomManager.h"
#import "DBPlayerData.h"

NS_ASSUME_NONNULL_BEGIN

@interface KJDownloaderConfiguration : NSObject
/// 单例属性
@property (nonatomic,strong,class,readonly,getter=kj_sharedInstance) KJDownloaderConfiguration *shared;

/// 正在下载的请求
@property (nonatomic,strong,readonly) NSMutableSet * downloadings;

#pragma mark - 下载地址管理

/// 新增网址
- (void)kj_addDownloadURL:(NSURL *)url;
/// 移出网址
- (void)kj_removeDownloadURL:(NSURL *)url;
/// 是否包含网址
- (BOOL)kj_containsDownloadURL:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
