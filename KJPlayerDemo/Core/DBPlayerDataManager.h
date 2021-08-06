//
//  DBPlayerDataManager.h
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/7.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo
//  本地数据库模型和工具

#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN
@class DBPlayerData;
@interface DBPlayerDataManager : NSObject

/// 插入数据，重复数据替换处理
/// @param dbid 主键ID
/// @param insert 插入回调
/// @param error 错误信息
/// @return 返回数据数组
+ (NSArray<DBPlayerData*>*)kj_insertData:(NSString *)dbid
                                  insert:(void(^)(DBPlayerData * data))insert
                                   error:(NSError **)error;

/// 删除数据
/// @param dbid 主键ID
/// @return 返回数据数组
+ (NSArray<DBPlayerData*>*)kj_deleteData:(NSString *)dbid;

/// 新添加数据
/// @param insert 插入回调
/// @return 返回数据数组
+ (NSArray<DBPlayerData*>*)kj_addData:(void(^)(DBPlayerData * data))insert;

/// 更新数据
/// @param dbid 主键ID
/// @param update 更新回调
/// @return 返回数据数组
+ (NSArray<DBPlayerData*>*)kj_updateData:(NSString *)dbid
                                  update:(void(^)(DBPlayerData * data, BOOL * stop))update;

/// 查询数据，传空传全部数据
/// @param dbid 主键ID
/// @return 返回数据数组
+ (NSArray<DBPlayerData*>*)kj_checkData:(NSString * _Nullable)dbid;

/// 指定条件查询数据
/// @param data 数据
/// @param fromat 指定条件，例如查询现在以前的数据 @"data.saveTime < %d"
/// @param threshold 阈值，上面例子：NSDate.date.timeIntervalSince1970
/// @return 返回数据数组
+ (NSArray<DBPlayerData*>*)kj_checkAppointData:(DBPlayerData *)data
                                        fromat:(NSString *)fromat
                                     threshold:(id)threshold;

@end

NS_ASSUME_NONNULL_END
