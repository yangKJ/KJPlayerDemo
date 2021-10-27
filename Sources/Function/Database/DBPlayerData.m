//
//  DBPlayerData.m
//  KJPlayerDemo
//
//  Created by yangkejun on 2021/8/6.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import "DBPlayerData.h"
#import "DBPlayerDataManager.h"

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

/// 记录上次播放时间
+ (BOOL)kj_recordLastTime:(NSTimeInterval)time dbid:(NSString *)dbid{
    NSError * error = nil;
    NSArray * array = [DBPlayerDataManager kj_updateData:dbid update:^(DBPlayerData * data, BOOL * stop) {
        data.videoPlayTime = time;
    } error:&error];
    if (error) return NO;
    return array.count ? YES : NO;
}
/// 获取上次播放时间
+ (NSTimeInterval)kj_lastTimeWithDbid:(NSString *)dbid{
    NSArray *temps = [DBPlayerDataManager kj_checkData:dbid error:nil];
    if (temps.count == 0) return 0;
    DBPlayerData * data = temps.firstObject;
    return data.videoPlayTime;
}
/// 异步获取上次播放时间
+ (void)kj_asyncLastTimeWithDbid:(NSString *)dbid withBolck:(void(^)(NSTimeInterval time))withBolck{
    void (^kThread)(void) = ^{
        NSArray * temps = [DBPlayerDataManager kj_checkData:dbid error:nil];
        if (temps.count == 0) {
            withBolck ? withBolck(0) : nil;
        } else {
            DBPlayerData *data = temps.firstObject;
            withBolck ? withBolck(data.videoPlayTime) : nil;
        }
    };
    if (@available(iOS 10.0, *)) {
        [[[NSThread alloc] initWithBlock:^{
            kThread();
        }] start];
    } else {
        kThread();
    }
}
/// 存储记录上次播放时间
+ (void)kj_saveRecordLastTime:(NSTimeInterval)time dbid:(NSString *)dbid{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (![DBPlayerData kj_recordLastTime:time dbid:dbid]) {
            [DBPlayerData kj_recordLastTime:time dbid:dbid];
            return;
        }
    });
}

@end
