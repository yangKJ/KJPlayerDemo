//
//  KJFileHandleInfo.h
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/10.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo
//  缓存相关信息资源

#import <Foundation/Foundation.h>
#import "DBPlayerDataInfo.h"
#import "KJCacheManager.h"
/* 缓存相关信息通知 */
extern NSString *kPlayerFileHandleInfoNotification;
/* 缓存相关信息接收key */
extern NSString *kPlayerFileHandleInfoKey;
@interface KJFileHandleInfo : NSObject <NSCopying>
@property (nonatomic,strong,readonly) NSURL *videoURL;
@property (nonatomic,strong,readonly) NSString *fileName;
@property (nonatomic,strong,readonly) NSString *fileFormat;
/* 已缓存分片 */
@property (nonatomic,strong,readonly) NSArray *cacheFragments;
/* 已下载长度 */
@property (nonatomic,assign,readonly) int64_t downloadedBytes;
/* 下载进度 */
@property (nonatomic,assign,readonly) float progress;
/* 下载耗时 */
@property (nonatomic,assign) NSTimeInterval downloadTime;
/* 文件类型 */
@property (nonatomic,strong) NSString *contentType;
/* 文件大小总长度 */
@property (nonatomic,assign) NSUInteger contentLength;

/* 初始化，优先读取归档数据 */
+ (instancetype)kj_createFileHandleInfoWithURL:(NSURL*)url;
/* 归档存储 */
- (void)kj_keyedArchiverSave;
/* 继续写入碎片 */
- (void)kj_continueCacheFragmentRange:(NSRange)range;

@end
