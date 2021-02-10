//
//  DBPlayerDataInfo.h
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/7.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo
//  本地数据库模型和工具

#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN
@interface DBPlayerData : NSManagedObject
@property (nonatomic, retain) NSString *dbid;//唯一id，视频链接去除scheme然后md5
@property (nonatomic, retain) NSString *videoUrl;//视频链接
@property (nonatomic, assign) int64_t saveTime;//存储时间戳
@property (nonatomic, retain) NSString *sandboxPath;//沙盒地址
@property (nonatomic, retain) NSString *videoFormat;//视频格式
@property (nonatomic, assign) int64_t videoTime;//视频时间
@property (nonatomic, retain) NSData *videoData;//视频数据
@end

@interface DBPlayerDataInfo : NSObject
/* 单例属性 */
@property(nonatomic,strong,class,readonly,getter=kj_sharedInstance) DBPlayerDataInfo *shared;
/* 管理数据 */
@property(nonatomic,strong,readonly) NSManagedObjectContext *context;
/* 插入数据，重复数据替换处理 */
+ (NSArray<DBPlayerData*>*)kj_insertData:(NSString*)dbid Data:(void(^)(DBPlayerData *data))insert;
/* 删除数据 */
+ (NSArray<DBPlayerData*>*)kj_deleteData:(NSString*)dbid;
/* 新添加数据 */
+ (NSArray<DBPlayerData*>*)kj_addData:(void(^)(DBPlayerData *data))insert;
/* 更新数据 */
+ (NSArray<DBPlayerData*>*)kj_updateData:(NSString*)dbid Data:(void(^)(DBPlayerData *data, bool * stop))update;
/* 查询数据，传空传全部数据 */
+ (NSArray<DBPlayerData*>*)kj_checkData:(NSString * _Nullable)dbid;
/* 指定条件查询，例如查询现在以前的数据 */
// NSArray *temps = DBPlayerDataInfo.kCheckAppointDatas(NSDate.date.timeIntervalSince1970, @"saveTime < %d");
@property(nonatomic,copy,class,readonly)NSArray<DBPlayerData*>*(^kCheckAppointDatas)(int64_t, NSString *fromat);

@end

NS_ASSUME_NONNULL_END
