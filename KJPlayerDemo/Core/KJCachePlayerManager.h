//
//  KJCachePlayerManager.h
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/10.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo
//  缓存相关管理

#import <Foundation/Foundation.h>
#import "DBPlayerDataInfo.h"

NS_ASSUME_NONNULL_BEGIN
#define kCacheVideoDirectory [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:@"videos"]
#define kCacheImageDirectory [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:@"videoImages"]
#define kTempReadName @"player.temp.read"
@interface KJCachePlayerManager : NSObject
#pragma mark - NSFileManager
/* 删除指定文件 */
+ (BOOL)kj_removeFilePath:(NSString*)path;
/* 创建文件夹 */
+ (BOOL)kj_createFilePath:(NSString*)path;
/* 目录下有用的文件路径，排除临时文件 */
+ (NSArray*)kj_videoFilePaths;
/* 目录下的全部文件名，包含临时文件 */
+ (NSArray*)kj_videoAllFileNames;
/* 删除指定完整路径数据 */
+ (void)kj_removeAimPath:(NSString*)path,...;
/* 判断文件是否存在，存在拼接完整路径 */
+ (BOOL)kj_haveFileSandboxPath:(NSString * _Nonnull __strong * _Nonnull)path;
/* 清除视频缓存文件和数据库数据 */
+ (BOOL)kj_crearVideoCachedAndDatabase:(DBPlayerData*)data;

#pragma mark - Sandbox板块
/* 判断是否有缓存，返回缓存链接 */
@property(nonatomic,copy,class,readonly)void(^kJudgeHaveCacheURL)(void(^)(BOOL locality), NSURL * _Nonnull __strong * _Nonnull);
/* 创建视频缓存文件完整路径 */
+ (NSString*)kj_createVideoCachedPath:(NSURL*)url;
/* 追加视频临时缓存路径，用于播放器读取 */
+ (NSString*)kj_appendingVideoTempPath:(NSURL*)url;
/* 获取视频缓存大小 */
+ (int64_t)kj_videoCachedSize;
/* 清除全部视频缓存，暴露当前正在下载数据 */
+ (void)kj_clearAllVideoCache;
/* 清除指定视频缓存 */
+ (BOOL)kj_clearVideoCacheWithURL:(NSURL*)url;
/* 存入视频封面图 */
+ (void)kj_saveVideoCoverImage:(UIImage*)image VideoURL:(NSURL*)url;
/* 读取视频封面图 */
+ (UIImage*)kj_getVideoCoverImageWithURL:(NSURL*)url;
/* 清除视频封面图 */
+ (void)kj_clearVideoCoverImageWithURL:(NSURL*)url;
/* 清除全部封面缓存 */
+ (void)kj_clearAllVideoCoverImage;

@end

NS_ASSUME_NONNULL_END
