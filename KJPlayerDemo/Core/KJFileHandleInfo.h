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
#import "KJCachePlayerManager.h"
/* 缓存相关信息通知 */
extern NSString *kPlayerFileHandleInfoNotification;
/* 缓存相关信息接收key */
extern NSString *kPlayerFileHandleInfoKey;
@interface KJFileHandleInfo : NSObject <NSCopying>
@property (nonatomic,strong) NSString *contentType;
@property (nonatomic,assign) NSUInteger contentLength;
@property (nonatomic,strong,readonly) NSArray *cacheFragments;
@property (nonatomic,strong,readonly) NSURL *videoURL;
@property (nonatomic,strong,readonly) NSString *fileName;
@property (nonatomic,strong,readonly) NSString *fileFormat;
@property (nonatomic,assign,readonly) int64_t downloadedBytes;
@property (nonatomic,assign,readonly) float progress;
@property (nonatomic,assign,readonly) float downloadSpeed;
/* 初始化 */
+ (instancetype)kj_createFileHandleInfoWithURL:(NSURL*)url;
/* 归档存储 */
- (void)kj_keyedArchiverSave;
/* 继续写入碎片 */
- (void)kj_continueCacheFragmentRange:(NSRange)range;
/* 下载耗时 */
- (void)kj_downloadedBytes:(int64_t)bytes spentTime:(NSTimeInterval)time;

@end
