//
//  KJFileHandleInfo.h
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/10.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 告诉编译器保存当前的对齐方式，并将对齐方式设置为1字节
#pragma pack(push, 1)
/// 缓存碎片结构体
struct KJCacheFragment {
    NSInteger type;/// 0：本地碎片，1：远端碎片
    NSRange  range;/// 位置长度
};
typedef struct KJCacheFragment KJCacheFragment;
/// 告诉编译器恢复保存的对齐方式
#pragma pack(pop)

/// 缓存相关信息资源
@interface KJFileHandleInfo : NSObject <NSCopying>
/// 链接地址
@property (nonatomic,strong,readonly) NSURL *videoURL;
/// 文件名，视频链接去掉SCHEME然后MD5
@property (nonatomic,strong,readonly) NSString *fileName;
/// 文件信息
@property (nonatomic,strong,readonly) NSString *fileFormat;
/// 已缓存分片 
@property (nonatomic,strong,readonly) NSArray *cacheFragments;
/// 已下载长度 
@property (nonatomic,assign,readonly) int64_t downloadedBytes;
/// 下载进度 
@property (nonatomic,assign,readonly) float progress;
/// 下载耗时 
@property (nonatomic,assign) NSTimeInterval downloadTime;
/// 文件类型 
@property (nonatomic,strong) NSString *contentType;
/// 文件大小总长度 
@property (nonatomic,assign) NSUInteger contentLength;

/// 初始化，优先读取归档数据 
+ (instancetype)kj_createFileHandleInfoWithURL:(NSURL *)url;

/// 归档存储 
- (void)kj_keyedArchiverSave;

/// 继续写入碎片 
- (void)kj_continueCacheFragmentRange:(NSRange)range;

#pragma mark - 结构体相关

/// 缓存碎片结构体转对象
+ (NSValue *)kj_cacheFragment:(KJCacheFragment)fragment;
/// 缓存碎片对象转结构体
+ (KJCacheFragment)kj_getCacheFragment:(id)obj;

#pragma mark - NSFileManager

/// 创建文件夹
/// @param path 路径
+ (BOOL)kj_createFilePath:(NSString *)path;

#pragma mark - Sandbox板块

/// 创建视频缓存文件完整路径
/// @param url 链接
+ (NSString *)kj_createVideoCachedPath:(NSURL *)url;

/// 追加视频临时缓存路径，用于播放器读取
/// @param url 链接
+ (NSString *)kj_appendingVideoTempPath:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
