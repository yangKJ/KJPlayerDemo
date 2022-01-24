//
//  KJDownloaderCommon.h
//  KJPlayer
//
//  Created by 77。 on 2021/8/18.
//  https://github.com/yangKJ/KJPlayerDemo

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 下载模块错误情况
typedef NS_ENUM(NSInteger, KJDownloaderFailedCode) {
    /// 缓存成功
    KJDownloaderFailedCodeCachedSuccessful,
    /// 读取缓存文件失败
    KJDownloaderFailedCodeReadCachedDataFailed,
    /// 写入缓存文件失败
    KJDownloaderFailedCodeWriteFileFailed,
};
/// 缓存相关信息通知
UIKIT_EXTERN NSNotificationName const kPlayerFileHandleInfoNotification;
/// 缓存相关信息接收key
UIKIT_EXTERN NSNotificationName const kPlayerFileHandleInfoKey;

// 临时路径名称
#define PLAYER_TEMP_READ_NAME @"player.temp.read"
// 缓存路径
#define PLAYER_CACHE_PATH NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject
#define PLAYER_CACHE_VIDEO_DIRECTORY [PLAYER_CACHE_PATH stringByAppendingPathComponent:@"videos"]

/// 下载器公共配置信息
@interface KJDownloaderCommon : NSObject

/// 单例属性
@property (nonatomic,strong,class,readonly,getter=kj_sharedInstance) KJDownloaderCommon *shared;

/// 正在下载的请求
@property (nonatomic,strong,readonly) NSMutableSet * downloadings;

#pragma mark - 下载地址管理

/// 新增网址
- (void)kj_addDownloadURL:(NSURL *)url;
/// 移出网址
- (void)kj_removeDownloadURL:(NSURL *)url;
/// 是否包含网址
- (BOOL)kj_containsDownloadURL:(NSURL *)url;

extern NSString * kMD5FileNameFormVideoURL(NSURL * videoURL);

@end

NS_ASSUME_NONNULL_END
