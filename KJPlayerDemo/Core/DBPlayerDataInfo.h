//
//  DBPlayerDataInfo.h
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/7.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo
//  本地数据库模型和工具

#import <CoreData/CoreData.h>
#import "KJPlayerType.h"

NS_ASSUME_NONNULL_BEGIN
@class DBPlayerData;
@interface DBPlayerDataInfo : NSObject
/// 单例属性 
@property(nonatomic,strong,class,readonly,getter=kj_sharedInstance) DBPlayerDataInfo *shared;
/// 管理数据 
@property(nonatomic,strong,readonly) NSManagedObjectContext *context;
@property(nonatomic,strong,readonly) NSMutableSet *downloadings;
/// 插入数据，重复数据替换处理
/// @param dbid 主键ID
/// @param insert 插入回调
/// @param error 错误信息
/// @return 返回数据数组
+ (NSArray<DBPlayerData*>*)kj_insertData:(NSString*)dbid  
                                  insert:(void(^)(DBPlayerData *data))insert
                                   error:(NSError**)error;
/// 删除数据
/// @param dbid 主键ID
/// @return 返回数据数组
+ (NSArray<DBPlayerData*>*)kj_deleteData:(NSString*)dbid;
/// 新添加数据
/// @param insert 插入回调
/// @return 返回数据数组
+ (NSArray<DBPlayerData*>*)kj_addData:(void(^)(DBPlayerData *data))insert;
/// 更新数据
/// @param dbid 主键ID
/// @param update 更新回调
/// @return 返回数据数组
+ (NSArray<DBPlayerData*>*)kj_updateData:(NSString*)dbid
                                  update:(void(^)(DBPlayerData *data, BOOL * stop))update;
/// 查询数据，传空传全部数据
/// @param dbid 主键ID
/// @return 返回数据数组
+ (NSArray<DBPlayerData*>*)kj_checkData:(NSString * _Nullable)dbid;
/// 指定条件查询，例如查询现在以前的数据 
// NSArray *temps = DBPlayerDataInfo.kCheckAppointDatas(NSDate.date.timeIntervalSince1970, @"saveTime < %d");
@property(nonatomic,copy,class,readonly)NSArray<DBPlayerData*>*(^kCheckAppointDatas)(int64_t, NSString *fromat);
/// 记录上次播放时间
/// @param time 当前播放时间
/// @param dbid 主键ID
+ (BOOL)kj_recordLastTime:(NSTimeInterval)time dbid:(NSString*)dbid;
/// 获取上次播放时间 
+ (NSTimeInterval)kj_getLastTimeDbid:(NSString*)dbid;
/// 异步获取上次播放时间 
+ (void)kj_gainLastTimeDbid:(NSString*)dbid Time:(void(^)(NSTimeInterval time))block;
/// 存储记录上次播放时间
+ (void)kj_saveRecordLastTime:(NSTimeInterval)time dbid:(NSString*)dbid;

#pragma mark - 下载地址管理
/// 新增网址 
- (void)kj_addDownloadURL:(NSURL*)url;
/// 移出网址 
- (void)kj_removeDownloadURL:(NSURL*)url;
/// 是否包含网址 
- (BOOL)kj_containsDownloadURL:(NSURL*)url;

#pragma mark - 结构体相关
/// 缓存碎片结构体转对象 
+ (NSValue*)kj_cacheFragment:(KJCacheFragment)fragment;
/// 缓存碎片对象转结构体 
+ (KJCacheFragment)kj_getCacheFragment:(id)obj;

#pragma mark - 错误提示汇总
/// 创建指定错误 
+ (NSError*)kj_errorSummarizing:(NSInteger)code;

#pragma mark - 日志打印
/// 打印日志 
#define PLAYERNSLog(type, frmt, ...) [DBPlayerDataInfo kj_log:type format:frmt, ##__VA_ARGS__]
#define PLAYERLogInfo(frmt, ...)     PLAYERNSLog(KJPlayerVideoRankTypeAll,frmt, ##__VA_ARGS__)
#define PLAYERLogOneInfo(frmt, ...)  PLAYERNSLog(KJPlayerVideoRankTypeOne,frmt, ##__VA_ARGS__)
#define PLAYERLogTwoInfo(frmt, ...)  PLAYERNSLog(KJPlayerVideoRankTypeTwo,frmt, ##__VA_ARGS__)
/// 打开几级日志打印，多枚举 
+ (void)kj_openLogRankType:(KJPlayerVideoRankType)type;
/// 按级别打印日志 
+ (void)kj_log:(KJPlayerVideoRankType)type format:(NSString*)format,...;

@end

@interface DBPlayerData : NSManagedObject

@property (nonatomic,retain) NSString *dbid;//唯一id，视频链接去除scheme然后md5
@property (nonatomic,retain) NSString *videoUrl;//视频链接
@property (nonatomic,assign) int64_t saveTime;//存储时间戳
@property (nonatomic,retain) NSString *sandboxPath;//沙盒地址
@property (nonatomic,retain) NSString *videoFormat;//视频格式
@property (nonatomic,assign) int64_t videoContentLength;//视频内容长度
@property (nonatomic,assign) Boolean videoIntact;//视频已下载完成
@property (nonatomic,retain) NSData *videoData;//视频数据
@property (nonatomic,assign) int64_t videoPlayTime;//视频上次播放时间

@end

NS_ASSUME_NONNULL_END
