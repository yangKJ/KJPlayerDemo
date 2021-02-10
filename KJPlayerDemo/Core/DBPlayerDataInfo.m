//
//  DBPlayerDataInfo.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/7.
//  Copyright © 2021 杨科军. All rights reserved.
//

#import "DBPlayerDataInfo.h"
static NSString * const kDBPlayerData = @"DBPlayerData";
@interface DBPlayerDataInfo()
@property(nonatomic,strong) NSManagedObjectContext *context;
@end
@implementation DBPlayerDataInfo
static DBPlayerDataInfo *_instance = nil;
static dispatch_once_t onceToken;
+ (instancetype)kj_sharedInstance{
    dispatch_once(&onceToken, ^{
        if (_instance == nil) {
            _instance = [[self alloc] init];
        }
    });
    return _instance;
}
- (instancetype)init{
    if (self == [super init]) {
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"DBPlayer" withExtension:@"momd"];
        NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
        NSPersistentStoreCoordinator *store = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
        NSString *docStr = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *sqlPath = [docStr stringByAppendingPathComponent:@"db_player_video.sqlite"];
        NSError *error = nil;
        [store addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[NSURL fileURLWithPath:sqlPath] options:nil error:&error];
        NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        context.persistentStoreCoordinator = store;
        self.context = context;
    }
    return self;
}

#pragma mark - DB 增删改查板块
/* 插入数据 */
+ (NSArray<DBPlayerData*>*)kj_insertData:(NSString*)dbid Data:(void(^)(DBPlayerData *data))insert{
    NSFetchRequest *checkRequest = [NSFetchRequest fetchRequestWithEntityName:kDBPlayerData];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dbid = %@", dbid];
    checkRequest.predicate = predicate;
    NSArray *checkArray = [DBPlayerDataInfo.shared.context executeFetchRequest:checkRequest error:nil];
    for (DBPlayerData *data in checkArray) {
        [DBPlayerDataInfo.shared.context deleteObject:data];
    }
    DBPlayerData * data = [NSEntityDescription insertNewObjectForEntityForName:kDBPlayerData inManagedObjectContext:DBPlayerDataInfo.shared.context];
    if (insert) insert(data);
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:kDBPlayerData];
    NSArray *resArray = [DBPlayerDataInfo.shared.context executeFetchRequest:request error:nil];
    NSError *error = nil;
    [DBPlayerDataInfo.shared.context save:&error];
    return resArray;
}
/* 删除数据 */
+ (NSArray<DBPlayerData*>*)kj_deleteData:(NSString*)dbid{
    NSFetchRequest *deleRequest = [NSFetchRequest fetchRequestWithEntityName:kDBPlayerData];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dbid = %@", dbid];
    deleRequest.predicate = predicate;
    NSArray *deleArray = [DBPlayerDataInfo.shared.context executeFetchRequest:deleRequest error:nil];
    for (DBPlayerData *data in deleArray) {
        [DBPlayerDataInfo.shared.context deleteObject:data];
    }
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:kDBPlayerData];
    NSArray *resArray = [DBPlayerDataInfo.shared.context executeFetchRequest:request error:nil];
    NSError *error = nil;
    [DBPlayerDataInfo.shared.context save:&error];
    return resArray;
}
/* 新添加数据 */
+ (NSArray<DBPlayerData*>*)kj_addData:(void(^)(DBPlayerData *data))insert{
    DBPlayerData * data = [NSEntityDescription insertNewObjectForEntityForName:kDBPlayerData inManagedObjectContext:DBPlayerDataInfo.shared.context];
    if (insert) insert(data);
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:kDBPlayerData];
    NSArray *resArray = [DBPlayerDataInfo.shared.context executeFetchRequest:request error:nil];
    NSError *error = nil;
    [DBPlayerDataInfo.shared.context save:&error];
    return resArray;
}
/* 更新数据 */
+ (NSArray<DBPlayerData*>*)kj_updateData:(NSString*)dbid Data:(void(^)(DBPlayerData *data, bool * stop))update{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:kDBPlayerData];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dbid = %@", dbid];
    request.predicate = predicate;
    NSArray *resArray = [DBPlayerDataInfo.shared.context executeFetchRequest:request error:nil];
    if (update) {
        for (DBPlayerData *data in resArray) {
            bool stop = false;
            update(data,&stop);
            if (stop) break;
        }
    }
    NSError *error = nil;
    [DBPlayerDataInfo.shared.context save:&error];
    return resArray;
}
/* 查询数据 */
+ (NSArray<DBPlayerData*>*)kj_checkData:(NSString*)dbid{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:kDBPlayerData];
    if (dbid != nil && dbid.length != 0 &&  ![dbid isEqualToString:@""]) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dbid = %@", dbid];
        request.predicate = predicate;
    }
    return [DBPlayerDataInfo.shared.context executeFetchRequest:request error:nil];
}
/* 指定条件查询，例如查询现在以前的数据 */
// NSArray *temps = DBPlayerDataInfo.kCheckAppointDatas(CFAbsoluteTimeGetCurrent(), @"saveTime < %d");
+ (NSArray<DBPlayerData*>*(^)(int64_t, NSString *fromat))kCheckAppointDatas{
    return ^NSArray<DBPlayerData*>*(int64_t ap, NSString *fromat){
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:kDBPlayerData];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:fromat, ap];
        request.predicate = predicate;
        return [DBPlayerDataInfo.shared.context executeFetchRequest:request error:nil];
    };
}

#pragma mark - Sandbox板块
//判断存放视频的文件夹是否存在，不存在则创建对应文件夹
NS_INLINE BOOL kPlayerNewFile(void){
    NSString *document = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES).lastObject;
    NSString *path = [document stringByAppendingPathComponent:@"video"];
    NSMutableString *string = [[NSMutableString alloc] init];
    [string setString:path];
    CFStringTrimWhitespace((CFMutableStringRef)string);
    if ([string length] == 0) return NO;
    NSString *finalPath = [NSTemporaryDirectory() stringByAppendingPathComponent:path];
    if (![[NSFileManager defaultManager] fileExistsAtPath:finalPath]) {
        return [[NSFileManager defaultManager] createDirectoryAtPath:finalPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return YES;
}
//获取目录下的全部文件
NS_INLINE NSArray * kPlayerTargetPathFiles(NSString * path){
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
    NSMutableArray *temps = [NSMutableArray array];
    NSString *imageName;
    while((imageName = [enumerator nextObject]) != nil) {
        [temps addObject:imageName];
    }
    return temps.mutableCopy;
}
//删除文件夹下的所有文件
NS_INLINE BOOL kPlayerRemoveTotalFiles(NSString * path){
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[NSTemporaryDirectory() stringByAppendingPathComponent:path] error:NULL];
    NSEnumerator *enumerator = [contents objectEnumerator];
    NSString *filename;
    while ((filename = [enumerator nextObject])) {
        [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/%@/%@",NSTemporaryDirectory(),path,filename] error:NULL];
    }
    return YES;
}
//判断文件是否存在 存在返回文件路径
NS_INLINE NSString * kPlayerIsExistFile(NSString * path){
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    if ([fileManager fileExistsAtPath:[NSTemporaryDirectory() stringByAppendingPathComponent:path]]){
        return [NSTemporaryDirectory() stringByAppendingPathComponent:path];
    }
    return nil;
}
//删除指定文件
NS_INLINE BOOL kPlayerRemoveFile(NSString * path){
    if (kPlayerIsExistFile(path) != nil){
        NSString *loc_path = [NSString stringWithFormat:@"%@/%@",NSTemporaryDirectory(),path];
        [[NSFileManager defaultManager] removeItemAtPath:loc_path error:NULL];
        return YES;
    }
    return NO;
}

@end
@implementation DBPlayerData
@dynamic dbid;
@dynamic videoUrl;
@dynamic saveTime;
@dynamic sandboxPath;
@dynamic videoFormat;
@dynamic videoTime;
@dynamic videoData;
@end
