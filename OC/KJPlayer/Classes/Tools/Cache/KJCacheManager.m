//
//  KJCacheManager.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/10.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJCacheManager.h"
#import "DBPlayerDataManager.h"
#import "KJPlayerConst.h"

@implementation KJCacheManager

#pragma mark - NSFileManager
/// 删除指定文件 
+ (BOOL)kj_removeFilePath:(NSString *)path{
    NSError * error = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
    } else {
        return YES;
    }
    return error == nil ? YES : NO;
}
/// 创建文件夹 
+ (BOOL)kj_createFilePath:(NSString *)path{
    NSError * error = nil;
    NSString *cacheFolder = [path stringByDeletingLastPathComponent];
    if (![[NSFileManager defaultManager] fileExistsAtPath:cacheFolder]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:cacheFolder
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&error];
    } else {
        return NO;
    }
    return error == nil ? YES : NO;
}
/// 目录下的全部文件名 
+ (NSArray *)kj_videoAllFileNames{
    return [[NSFileManager defaultManager] contentsOfDirectoryAtPath:PLAYER_CACHE_VIDEO_DIRECTORY
                                                               error:nil];
}
/// 目录下有用的文件路径，排除临时文件 
+ (NSArray *)kj_videoFilePaths{
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager]
                                         enumeratorAtPath:PLAYER_CACHE_VIDEO_DIRECTORY];
    NSMutableArray *temps = [NSMutableArray array];
    NSString *name;
    while ((name = [enumerator nextObject]) != nil) {
        if ([name hasSuffix:PLAYER_TEMP_READ_NAME]) continue;
        [temps addObject:[PLAYER_CACHE_VIDEO_DIRECTORY stringByAppendingPathComponent:name]];
    }
    return temps.mutableCopy;
}
/// 删除指定路径数据 
+ (void)kj_removeAimPath:(NSString *)path,...{
    NSMutableArray *paths = [NSMutableArray arrayWithObject:path];
    va_list args;NSString *arg;
    va_start(args, path);
    while ((arg = va_arg(args, NSString *))) {
        [paths addObject:arg];
    }
    va_end(args);
    for (NSString *removePath in paths) {
        [[NSFileManager defaultManager] removeItemAtPath:removePath error:NULL];
    }
}
/// 判断文件是否存在，存在拼接完整路径 
+ (BOOL)kj_haveFileSandboxPath:(NSString * _Nonnull __strong * _Nonnull)path{
    NSString *tempPath = [PLAYER_CACHE_VIDEO_DIRECTORY stringByAppendingPathComponent:*path];
    if ([[NSFileManager defaultManager] fileExistsAtPath:tempPath]) {
        * path = tempPath;
        return YES;
    } else {
        return NO;
    }
}
/// 清除视频缓存文件和数据库数据 
+ (BOOL)kj_crearVideoCachedAndDatabase:(DBPlayerData *)data{
    NSString *sanboxPath = data.sandboxPath;
    if ([self kj_haveFileSandboxPath:&sanboxPath]) {
        NSString *tempPath = [sanboxPath stringByAppendingPathExtension:PLAYER_TEMP_READ_NAME];
        if ([[NSFileManager defaultManager] fileExistsAtPath:tempPath]) {
            if (![[NSFileManager defaultManager] removeItemAtPath:tempPath error:NULL]) {
                return NO;
            }
        }
        if ([[NSFileManager defaultManager] removeItemAtPath:sanboxPath error:NULL]) {
            NSError * error = nil;
            [DBPlayerDataManager kj_deleteData:data.dbid error:&error];
            return error ? NO : YES;
        }
    }
    return NO;
}

#pragma mark - Sandbox板块

/// 判断是否有缓存，返回缓存链接
/// @param videoURL 链接地址
+ (BOOL)kj_haveCacheURL:(NSURL * _Nonnull __strong * _Nonnull)videoURL{
    NSURL * tempURL = * videoURL;
    NSArray<DBPlayerData*> * temps = [DBPlayerDataManager kj_checkData:kPlayerIntactName(tempURL)
                                                                 error:nil];
    if (temps.count) {
        DBPlayerData * data = temps.firstObject;
        NSString * path = data.sandboxPath;
        if (data.videoIntact && [KJCacheManager kj_haveFileSandboxPath:&path]) {
            NSString *tempPath = [path stringByAppendingPathExtension:PLAYER_TEMP_READ_NAME];
            [[NSFileManager defaultManager] removeItemAtPath:tempPath error:NULL];
            * videoURL = [NSURL fileURLWithPath:path];
            return YES;
        }
    }
    return NO;
}
/// 创建缓存文件完整路径 
+ (NSString *)kj_createVideoCachedPath:(NSURL *)url{
    NSString *pathComponent = kPlayerIntactName(url);
    pathComponent = [pathComponent stringByAppendingPathExtension:url.pathExtension];
    return [PLAYER_CACHE_VIDEO_DIRECTORY stringByAppendingPathComponent:pathComponent];
}
/// 追加临时缓存路径，用于播放器读取 
+ (NSString *)kj_appendingVideoTempPath:(NSURL *)url{
    return [[self kj_createVideoCachedPath:url] stringByAppendingPathExtension:PLAYER_TEMP_READ_NAME];
}
/// 获取缓存大小 
+ (int64_t)kj_videoCachedSize{
    int64_t size = 0;
    for (NSString *name in [self kj_videoAllFileNames]) {
        NSString *filePath = [PLAYER_CACHE_VIDEO_DIRECTORY stringByAppendingPathComponent:name];
        NSDictionary *dict = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        if (dict == nil) continue;
        size += [dict fileSize];
    }
    return size;
}
/// 清除全部缓存，暴露当前正在下载数据 
+ (void)kj_clearAllVideoCache{
    for (NSString *name in [self kj_videoAllFileNames]) {
        NSString *filePath = [PLAYER_CACHE_VIDEO_DIRECTORY stringByAppendingPathComponent:name];
        [self kj_removeFilePath:filePath];
    }
}
/// 清除指定缓存 
+ (BOOL)kj_clearVideoCacheWithURL:(NSURL *)url{
    if (url == nil) return NO;
    NSString *tempPath = [self kj_appendingVideoTempPath:url];
    NSFileManager * manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:tempPath]) {
        if (![manager removeItemAtPath:tempPath error:NULL]) {
            return NO;
        }
    }
    return [manager removeItemAtPath:[self kj_createVideoCachedPath:url] error:NULL];
}

@end
