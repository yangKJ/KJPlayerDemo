//
//  KJFileHandleManager.h
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/10.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo
//  写入和读取文件管理

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "KJFileHandleInfo.h"

@interface KJFileHandleManager : NSObject
@property (nonatomic,strong,readonly) KJFileHandleInfo *cacheInfo;
- (instancetype)initWithURL:(NSURL*)url;
/* 设置需要写入的总长度 */
- (void)kj_setWriteHandleContentLenght:(NSUInteger)contentLength;
/* 获取指定区间已经缓存的碎片 */
- (NSArray*)kj_getCachedFragmentsWithRange:(NSRange)range;
/* 写入已下载分片数据 */
- (NSError*)kj_writeCacheData:(NSData*)data Range:(NSRange)range;
/* 读取已下载分片缓存数据 */
- (NSData*)kj_readCachedDataWithRange:(NSRange)range;
/* 写入存储 */
- (void)kj_writeSave;
/* 开始写入 */
- (void)kj_startWritting;
/* 结束写入 */
- (void)kj_finishWritting;

@end
