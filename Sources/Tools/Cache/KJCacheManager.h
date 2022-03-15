//
//  KJCacheManager.h
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/10.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo
//  缓存相关管理

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class DBPlayerData;
@interface KJCacheManager : NSObject

#pragma mark - NSFileManager

/// 删除指定文件
/// @param path 路径
+ (BOOL)kj_removeFilePath:(NSString *)path;

/// 创建文件夹
/// @param path 路径
+ (BOOL)kj_createFilePath:(NSString *)path;

/// 目录下有用的文件路径，排除临时文件 
+ (NSArray *)kj_videoFilePaths;

/// 目录下的全部文件名，包含临时文件 
+ (NSArray *)kj_videoAllFileNames;

/// 删除指定完整路径数据
/// @param path 不定参路径
+ (void)kj_removeAimPath:(NSString *)path,...;

/// 判断文件是否存在，存在拼接完整路径
/// @param path 路径
+ (BOOL)kj_haveFileSandboxPath:(NSString * _Nonnull __strong * _Nonnull)path;

/// 清除视频缓存文件和数据库数据
/// @param data 清除数据
+ (BOOL)kj_crearVideoCachedAndDatabase:(DBPlayerData *)data;

#pragma mark - Sandbox板块

/// 判断是否有缓存，返回缓存链接
/// @param videoURL 链接地址
/// @return 返回是否存在缓存
+ (BOOL)kj_haveCacheURL:(NSURL * _Nonnull __strong * _Nonnull)videoURL;

/// 创建视频缓存文件完整路径
/// @param url 链接
+ (NSString *)kj_createVideoCachedPath:(NSURL *)url;

/// 追加视频临时缓存路径，用于播放器读取
/// @param url 链接
+ (NSString *)kj_appendingVideoTempPath:(NSURL *)url;

/// 获取视频缓存大小 
+ (int64_t)kj_videoCachedSize;

/// 清除全部视频缓存，暴露当前正在下载数据 
+ (void)kj_clearAllVideoCache;

/// 清除指定视频缓存
/// @param url 链接
+ (BOOL)kj_clearVideoCacheWithURL:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
