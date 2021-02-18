//
//  DBPlayerDataInfo.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/7.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import "DBPlayerDataInfo.h"

@implementation DBPlayerData
@dynamic dbid;
@dynamic videoUrl;
@dynamic saveTime;
@dynamic sandboxPath;
@dynamic videoFormat;
@dynamic videoContentLength;
@dynamic videoData;
@dynamic videoIntact;
@dynamic videoPlayTime;
@end
@interface DBPlayerDataInfo()
@property(nonatomic,strong) NSManagedObjectContext *context;
@property(nonatomic,strong) NSMutableSet *downloadings;
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
- (NSMutableSet *)downloadings{
    if (!_downloadings) {
        _downloadings = [NSMutableSet set];
    }
    return _downloadings;
}

#pragma mark - DB 增删改查板块
static NSString * const kDBPlayerData = @"DBPlayerData";
/* 插入数据 */
+ (NSArray<DBPlayerData*>*)kj_insertData:(NSString*)dbid Data:(void(^)(DBPlayerData *data))insert error:(NSError**)error{
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
    [DBPlayerDataInfo.shared.context save:error];
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
+ (NSArray<DBPlayerData*>*)kj_updateData:(NSString*)dbid Data:(void(^)(DBPlayerData *data, BOOL * stop))update{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:kDBPlayerData];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dbid = %@", dbid];
    request.predicate = predicate;
    NSArray *resArray = [DBPlayerDataInfo.shared.context executeFetchRequest:request error:nil];
    if (update) {
        if (resArray.count == 0) {
            NSMutableArray *temps = [NSMutableArray array];
            DBPlayerData * data = [NSEntityDescription insertNewObjectForEntityForName:kDBPlayerData inManagedObjectContext:DBPlayerDataInfo.shared.context];
            data.dbid = dbid;
            BOOL stop = NO;
            update(data,&stop);
            [temps addObject:data];
            resArray = temps.mutableCopy;
        }else{
            for (DBPlayerData *data in resArray) {
                BOOL stop = NO;
                update(data,&stop);
                if (stop) break;
            }
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
/* 记录上次播放时间 */
+ (BOOL)kj_recordLastTime:(NSTimeInterval)time dbid:(NSString*)dbid{
    NSArray *temps = [DBPlayerDataInfo kj_updateData:dbid Data:^(DBPlayerData *data, BOOL * stop) {
        data.videoPlayTime = time;
    }];
    return temps.count;
}
/* 获取上次播放时间 */
+ (NSTimeInterval)kj_getLastTimeDbid:(NSString*)dbid{
    NSArray *temps = [DBPlayerDataInfo kj_checkData:dbid];
    if (temps.count == 0) return 0;
    DBPlayerData *data = temps.firstObject;
    return data.videoPlayTime;
}
/* 存储记录上次播放时间 */
void kRecordLastTime(NSTimeInterval time, NSString *dbid){
    kGCD_player_async(^{
        if (![DBPlayerDataInfo kj_recordLastTime:time dbid:dbid]) {
            [DBPlayerDataInfo kj_recordLastTime:time dbid:dbid];
        }
    });
}

#pragma mark - 下载地址管理
- (void)kj_addDownloadURL:(NSURL*)url{
    @synchronized (self.downloadings) {
        [self.downloadings addObject:url];
    }
}
- (void)kj_removeDownloadURL:(NSURL*)url{
    @synchronized (self.downloadings) {
        [self.downloadings removeObject:url];
    }
}
- (BOOL)kj_containsDownloadURL:(NSURL*)url{
    @synchronized (self.downloadings) {
        return [self.downloadings containsObject:url];
    }
}
#pragma mark - 结构体相关
/* 缓存碎片结构体转对象 */
+ (NSValue*)kj_cacheFragment:(KJCacheFragment)fragment{
    return [NSValue valueWithBytes:&fragment objCType:@encode(struct KJCacheFragment)];
}
/* 缓存碎片对象转结构体 */
+ (KJCacheFragment)kj_getCacheFragment:(id)obj{
    KJCacheFragment fragment;
    [obj getValue:&fragment];
    return fragment;
}

#pragma mark - 错误提示汇总
/**网络错误相关，
 * 请求超时：-1001
 * 找不到服务器：-1003
 * 服务器内部错误：-1004
 * 网络中断：-1005
 * 无网络连接：-1009
 */
+ (NSError*)kj_errorSummarizing:(NSInteger)code{
    NSString *domain = @"unknown";
    NSDictionary *userInfo = nil;
    switch (code) {
        case KJPlayerCustomCodeCacheNone:
            domain = @"No cache data";
            break;
        case KJPlayerCustomCodeCachedComplete:
            domain = @"locality data";
            break;
        case KJPlayerCustomCodeSaveDatabase:
            domain = @"Succeed save database";
            break;
        case KJPlayerCustomCodeAVPlayerItemStatusUnknown:
            domain = @"Player item status unknown";
            break;
        case KJPlayerCustomCodeAVPlayerItemStatusFailed:
            domain = @"Player item status failed";
            break;
        case KJPlayerCustomCodeVideoURLUnknownFormat:
            domain = @"url unknown format";
            break;
        case KJPlayerCustomCodeVideoURLFault:
            domain = @"url fault";
            break;
        case KJPlayerCustomCodeWriteFileFailed:
            domain = @"write file failed";
            break;
        case KJPlayerCustomCodeReadCachedDataFailed:
            domain = @"Data read failed";
            break;
        case KJPlayerCustomCodeSaveDatabaseFailed:
            domain = @"Save database failed";
            break;
        case KJPlayerCustomCodeFinishLoading:
            domain = @"Resource loader cancelled";
            break;
        default:
            break;
    }
    return [NSError errorWithDomain:domain code:code userInfo:userInfo];
}

@end
