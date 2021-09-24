//
//  DBPlayerDataManager.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/7.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import "DBPlayerDataManager.h"

@implementation DBPlayerDataManager
static NSString * _resourceName = @"DBPlayer";
+ (NSString *)resourceName{
    return _resourceName;
}
+ (void)setResourceName:(NSString *)resourceName{
    _resourceName = resourceName;
}
static NSString * _sqliteName = @"db_player_video";
+ (NSString *)sqliteName{
    return _sqliteName;
}
+ (void)setSqliteName:(NSString *)sqliteName{
    _sqliteName = sqliteName;
}
/// 管理数据
static NSManagedObjectContext * _context = nil;
+ (NSManagedObjectContext *)context{
    if (!_context) {
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:[DBPlayerDataManager resourceName]
                                                  withExtension:@"momd"];
        NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
        NSPersistentStoreCoordinator *store = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
        NSString *docString = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *name = [NSString stringWithFormat:@"%@.sqlite", [DBPlayerDataManager sqliteName]];
        NSString *sqlPath = [docString stringByAppendingPathComponent:name];
        NSError * error = nil;
        [store addPersistentStoreWithType:NSSQLiteStoreType
                            configuration:nil
                                      URL:[NSURL fileURLWithPath:sqlPath]
                                  options:nil
                                    error:&error];
        _context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        _context.persistentStoreCoordinator = store;
    }
    return _context;
}

#pragma mark - DB 增删改查板块

static NSString * kDBPlayerData = @"DBPlayerData";
+ (NSString *)requestEntityName{
    return kDBPlayerData;
}
+ (void)setRequestEntityName:(NSString *)requestEntityName{
    kDBPlayerData = requestEntityName;
}
/// 插入数据，重复数据替换处理
/// @param dbid 主键ID
/// @param insert 插入回调
/// @param error 错误信息
/// @return 返回数据数组
+ (NSArray<DBPlayerData*>*)kj_insertOrReplaceData:(NSString *)dbid
                                           insert:(void(^)(DBPlayerData * data))insert
                                            error:(NSError **)error{
    NSFetchRequest *checkRequest = [NSFetchRequest fetchRequestWithEntityName:kDBPlayerData];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dbid = %@", dbid];
    checkRequest.predicate = predicate;
    NSArray *checkArray = [[DBPlayerDataManager context] executeFetchRequest:checkRequest error:nil];
    for (DBPlayerData * data in checkArray) {
        [[DBPlayerDataManager context] deleteObject:data];
    }
    DBPlayerData * data = [NSEntityDescription insertNewObjectForEntityForName:kDBPlayerData
                                                        inManagedObjectContext:[DBPlayerDataManager context]];
    if (insert) insert(data);
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:kDBPlayerData];
    NSArray *resArray = [[DBPlayerDataManager context] executeFetchRequest:request error:nil];
    [[DBPlayerDataManager context] save:error];
    return resArray;
}
/// 删除数据
/// @param dbid 主键ID
/// @return 返回数据数组
+ (NSArray<DBPlayerData*>*)kj_deleteData:(NSString *)dbid error:(NSError **)error{
    NSFetchRequest *deleRequest = [NSFetchRequest fetchRequestWithEntityName:kDBPlayerData];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dbid = %@", dbid];
    deleRequest.predicate = predicate;
    NSArray *deleArray = [[DBPlayerDataManager context] executeFetchRequest:deleRequest error:nil];
    for (DBPlayerData *data in deleArray) {
        [[DBPlayerDataManager context] deleteObject:data];
    }
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:kDBPlayerData];
    NSArray *resArray = [[DBPlayerDataManager context] executeFetchRequest:request error:nil];
    [[DBPlayerDataManager context] save:error];
    return resArray;
}
/// 新添加数据
/// @param insert 插入回调
/// @return 返回数据数组
+ (NSArray<DBPlayerData*>*)kj_addData:(void(^)(DBPlayerData * data))insert
                                error:(NSError **)error{
    DBPlayerData * data = [NSEntityDescription insertNewObjectForEntityForName:kDBPlayerData
                                                        inManagedObjectContext:[DBPlayerDataManager context]];
    if (insert) insert(data);
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:kDBPlayerData];
    NSArray *resArray = [[DBPlayerDataManager context] executeFetchRequest:request error:nil];
    [[DBPlayerDataManager context] save:error];
    return resArray;
}
/// 更新数据
/// @param dbid 主键ID
/// @param update 更新回调
/// @return 返回数据数组
+ (NSArray<DBPlayerData*>*)kj_updateData:(NSString *)dbid
                                  update:(void(^)(DBPlayerData * data, BOOL * stop))update
                                   error:(NSError **)error{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:kDBPlayerData];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dbid = %@", dbid];
    request.predicate = predicate;
    NSArray *resArray = [[DBPlayerDataManager context] executeFetchRequest:request error:nil];
    if (update) {
        if (resArray.count == 0) {
            NSMutableArray *temps = [NSMutableArray array];
            DBPlayerData * data =
            [NSEntityDescription insertNewObjectForEntityForName:kDBPlayerData
                                          inManagedObjectContext:[DBPlayerDataManager context]];
            data.dbid = dbid;
            BOOL stop = NO;
            update(data,&stop);
            [temps addObject:data];
            resArray = temps.mutableCopy;
        } else {
            for (DBPlayerData *data in resArray) {
                BOOL stop = NO;
                update(data,&stop);
                if (stop) break;
            }
        }
    }
    [[DBPlayerDataManager context] save:error];
    return resArray;
}
/// 查询数据，传空传全部数据
/// @param dbid 主键ID
/// @return 返回数据数组
+ (NSArray<DBPlayerData*>*)kj_checkData:(NSString *)dbid error:(NSError **)error{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:kDBPlayerData];
    if (dbid != nil && dbid.length != 0 && ![dbid isEqualToString:@""]) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dbid = %@", dbid];
        request.predicate = predicate;
    }
    return [[DBPlayerDataManager context] executeFetchRequest:request error:error];
}
/// 指定条件查询数据
/// @param data 数据
/// @param fromat 指定条件，例如查询现在以前的数据 `@"data.saveTime < %d"`
/// @param threshold 阈值，上面例子：NSDate.date.timeIntervalSince1970
/// @return 返回数据数组
+ (NSArray<DBPlayerData*>*)kj_checkAppointData:(DBPlayerData *)data
                                        fromat:(NSString *)fromat
                                     threshold:(id)threshold
                                         error:(NSError **)error{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:kDBPlayerData];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:fromat, threshold];
    request.predicate = predicate;
    return [[DBPlayerDataManager context] executeFetchRequest:request error:error];
}

@end
