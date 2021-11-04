//
//  DBPlayerDataManager.h
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/7.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo
//  本地数据库模型和工具

#import <CoreData/CoreData.h>
#import "DBPlayerData.h"

NS_ASSUME_NONNULL_BEGIN

@interface DBPlayerDataManager : NSObject

//********************** 配置信息，请在App启动时刻设置 **********************
/// 地址，默认 `DBPlayerData`
@property (nonatomic, strong, class) NSString * requestEntityName;
/// 数据库名，默认 `DBPlayer`
@property (nonatomic, strong, class) NSString * resourceName;
/// sqlite文件名，默认 `db_player_video`
@property (nonatomic, strong, class) NSString * sqliteName;

//********************** 配置信息，请在App启动时刻设置 **********************

/// 插入数据，重复数据替换处理
/// @param dbid 主键ID
/// @param insert 插入回调
/// @param error 错误信息
/// @return 返回数据数组
+ (NSArray<DBPlayerData*>*)kj_insertOrReplaceData:(NSString *)dbid
                                           insert:(void(^)(DBPlayerData * data))insert
                                            error:(inout NSError **)error;

/// 删除数据
/// @param dbid 主键ID
/// @param error 错误信息
/// @return 返回数据数组
+ (NSArray<DBPlayerData*>*)kj_deleteData:(NSString *)dbid
                                   error:(inout NSError **)error;

/// 新添加数据
/// @param insert 插入回调
/// @param error 错误信息
/// @return 返回数据数组
+ (NSArray<DBPlayerData*>*)kj_addData:(void(^)(DBPlayerData * data))insert
                                error:(inout NSError **)error;

/// 更新数据
/// @param dbid 主键ID
/// @param update 更新回调
/// @param error 错误信息
/// @return 返回数据数组
+ (NSArray<DBPlayerData*>*)kj_updateData:(NSString *)dbid
                                  update:(void(^)(DBPlayerData * data, BOOL * stop))update
                                   error:(inout NSError **)error;

/// 查询数据，传空传全部数据
/// @param dbid 主键ID
/// @param error 错误信息
/// @return 返回数据数组
+ (NSArray<DBPlayerData*>*)kj_checkData:(NSString * _Nullable)dbid
                                  error:(inout NSError **)error;

/// 指定条件查询数据
/// @param data 数据
/// @param fromat 指定条件，例如查询现在以前的数据 @"data.saveTime < %d"
/// @param threshold 阈值，上面例子：NSDate.date.timeIntervalSince1970
/// @param error 错误信息
/// @return 返回数据数组
+ (NSArray<DBPlayerData*>*)kj_checkAppointData:(DBPlayerData *)data
                                        fromat:(NSString *)fromat
                                     threshold:(id)threshold
                                         error:(inout NSError **)error;

@end

NS_ASSUME_NONNULL_END
