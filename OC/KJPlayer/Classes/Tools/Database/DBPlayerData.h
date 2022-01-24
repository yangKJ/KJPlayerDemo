//
//  DBPlayerData.h
//  KJPlayerDemo
//
//  Created by yangkejun on 2021/8/6.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo
//  数据库模型

#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface DBPlayerData : NSManagedObject

/// 主键ID，视频链接去除SCHEME然后MD5
@property (nonatomic,retain) NSString * dbid;
/// 视频链接
@property (nonatomic,retain) NSString * videoUrl;
/// 存储时间戳
@property (nonatomic,assign) int64_t saveTime;
/// 沙盒地址
@property (nonatomic,retain) NSString * sandboxPath;
/// 视频格式
@property (nonatomic,retain) NSString * videoFormat;
/// 视频内容长度
@property (nonatomic,assign) int64_t videoContentLength;
/// 视频已下载完成
@property (nonatomic,assign) Boolean videoIntact;
/// 视频数据
@property (nonatomic,retain) NSData * videoData;
/// 视频上次播放时间
@property (nonatomic,assign) int64_t videoPlayTime;

/// 记录上次播放时间
/// @param time 当前播放时间
/// @param dbid 主键ID
+ (BOOL)kj_recordLastTime:(NSTimeInterval)time dbid:(NSString *)dbid;

/// 获取上次播放时间
+ (NSTimeInterval)kj_lastTimeWithDbid:(NSString *)dbid;

/// 异步获取上次播放时间
/// @param dbid 主键ID
/// @param withBolck 播放时间回调
+ (void)kj_asyncLastTimeWithDbid:(NSString *)dbid withBolck:(void(^)(NSTimeInterval time))withBolck;

/// 存储记录上次播放时间
/// @param time 时间节点
/// @param dbid 主键ID
+ (void)kj_saveRecordLastTime:(NSTimeInterval)time dbid:(NSString *)dbid;

@end

NS_ASSUME_NONNULL_END
