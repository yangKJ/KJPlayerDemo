//
//  KJFileHandleManager.h
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/10.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import <Foundation/Foundation.h>
#import "KJFileHandleInfo.h"

NS_ASSUME_NONNULL_BEGIN

/// 写入和读取文件管理器
@interface KJFileHandleManager : NSObject
/// 缓存相关信息资源
@property (nonatomic,strong,readonly) KJFileHandleInfo *cacheInfo;

/// 初始化
/// @param url 链接地址
- (instancetype)initWithURL:(NSURL *)url;

/// 设置需要写入的总长度
/// @param contentLength 总长度
- (void)kj_setWriteHandleContentLenght:(NSUInteger)contentLength;

/// 获取指定区间已经缓存的碎片
/// @param range 指定区间
- (NSArray *)kj_getCachedFragmentsWithRange:(NSRange)range;

/// 写入已下载分片数据
/// @param data 写入数据
/// @param range 指定区间
- (NSError *)kj_writeCacheData:(NSData *)data range:(NSRange)range;

/// 读取已下载分片缓存数据
/// @param range 指定区间
- (NSData *)kj_readCachedDataWithRange:(NSRange)range;

/// 写入存储 
- (void)kj_writeSave;

/// 开始写入
- (void)kj_startWritting;

/// 结束写入
- (void)kj_finishWritting;

@end

NS_ASSUME_NONNULL_END
