//
//  KJFileHandleManager.h
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/10.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo
//  缓存管理

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "KJFileHandleInfo.h"

@interface KJFileHandleManager : NSObject
@property (nonatomic,strong,readonly) KJFileHandleInfo *cacheInfo;
- (instancetype)initWithURL:(NSURL*)url;
/* 已经缓存的碎片区域 */
- (NSArray*)kj_dealwithCachedFragmentsWithRange:(NSRange)range;
/* 写入数据至播放路径文件 */
- (void)kj_writeCacheData:(NSData*)data Range:(NSRange)range error:(NSError **)error;
/* 读取播放路径文件数据 */
- (NSData*)kj_readCachedDataWithRange:(NSRange)range;
/* 设置缓存长度和类型 */
- (void)kj_setContentLenght:(NSUInteger)contentLength contentType:(NSString*)contentType;
/* 写入存储 */
- (void)kj_writeSave;
/* 开始写入 */
- (void)kj_startWritting;
/* 结束写入 */
- (void)kj_finishWritting;

@end
