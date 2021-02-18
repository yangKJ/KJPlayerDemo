//
//  KJFileHandleInfo.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/10.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJFileHandleInfo.h"

NSString *kPlayerFileHandleInfoNotification = @"kPlayerFileHandleInfoNotification";
NSString *kPlayerFileHandleInfoKey = @"kPlayerFileHandleInfoKey";
@interface KJFileHandleInfo ()
@property (nonatomic,strong) NSArray *cacheFragments;
@property (nonatomic,strong) NSArray *downloadInfo;
@property (nonatomic,strong) NSURL *videoURL;
@property (nonatomic,strong) NSString *fileName;
@property (nonatomic,strong) NSString *fileFormat;
@end
@implementation KJFileHandleInfo
#pragma mark - NSCopying
- (id)copyWithZone:(nullable NSZone *)zone {
    KJFileHandleInfo *info = [[[self class] allocWithZone:zone] init];
    unsigned int count = 0;
    Ivar *ivars = class_copyIvarList([self class], &count);
    for (int i = 0; i<count; i++){
        const char *name = ivar_getName(ivars[i]);
        NSString *key = [NSString stringWithUTF8String:name];
        id value = [self valueForKey:key];
        if ([value respondsToSelector:@selector(copyWithZone:)]) {
            [info setValue:[value copy] forKey:key];
        }else{
            [info setValue:value forKey:key];
        }
    }
    free(ivars);
    return info;
}
/* 归档 */
- (void)encodeWithCoder:(NSCoder*)aCoder{
    unsigned int count = 0;
    Ivar *ivars = class_copyIvarList([self class], &count);
    for (int i = 0; i<count; i++){
        const char *name = ivar_getName(ivars[i]);
        NSString *key = [NSString stringWithUTF8String:name];
        id value = [self valueForKey:key];
        [aCoder encodeObject:value forKey:key];
    }
    free(ivars);
}
/* 解档 */
- (instancetype)initWithCoder:(NSCoder*)aDecoder{
    if (self == [super init]){
        unsigned int count = 0;
        Ivar *ivars = class_copyIvarList([self class], &count);
        for (int i = 0; i<count; i++){
            const char *name = ivar_getName(ivars[i]);
            NSString *key = [NSString stringWithUTF8String:name];
            id value = [aDecoder decodeObjectForKey:key];
            [self setValue:value forKey:key];
        }
        free(ivars);
    }
    return self;
}
+ (instancetype)kj_createFileHandleInfoWithURL:(NSURL*)url{
    KJFileHandleInfo *info = [NSKeyedUnarchiver unarchiveObjectWithFile:[KJCachePlayerManager kj_appendingVideoTempPath:url]];
    if (info == nil) info = [[KJFileHandleInfo alloc] init];
    info.videoURL = url;
    info.fileName = kPlayerIntactName(url);
    info.fileFormat = url.pathExtension;
    return info;
}
- (float)progress{
    return self.downloadedBytes / (float)self.contentLength;
}
- (int64_t)downloadedBytes{
    float bytes = 0;
    @synchronized (self.cacheFragments){
        for (NSValue *range in self.cacheFragments){
            bytes += range.rangeValue.length;
        }
    }
    return bytes;
}
- (float)downloadSpeed{
    long long bytes = 0;
    NSTimeInterval time = 0;
    @synchronized (self.downloadInfo){
        for (NSArray *array in self.downloadInfo){
            bytes += [array[0] longLongValue];
            time  += [array[1] doubleValue];
        }
    }
    return bytes / 1024.0 / time;
}
- (void)kj_keyedArchiverSave{
    @synchronized (self.cacheFragments){
        [NSKeyedArchiver archiveRootObject:self toFile:[KJCachePlayerManager kj_appendingVideoTempPath:self.videoURL]];
    }
}
- (void)kj_continueCacheFragmentRange:(NSRange)range{
    if (range.location == NSNotFound || range.length == 0){
        return;
    }
    @synchronized (self.cacheFragments){
        NSMutableArray<NSValue*>*temps = [NSMutableArray arrayWithArray:self.cacheFragments];
        NSInteger count = temps.count;
        if (count == 0){
            [temps addObject:[NSValue valueWithRange:range]];
        }else{
            NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
            [temps enumerateObjectsUsingBlock:^(NSValue *obj, NSUInteger idx, BOOL *stop){
                NSRange ran = obj.rangeValue;
                if ((range.location + range.length) <= ran.location){
                    if (indexSet.count == 0){
                        [indexSet addIndex:idx];
                    }
                    *stop = YES;
                }else if (range.location <= (ran.location + ran.length) &&
                          (range.location + range.length) > ran.location){
                    [indexSet addIndex:idx];
                }else if (range.location >= ran.location + ran.length){
                    if (idx == count - 1){ 
                        [indexSet addIndex:idx];
                    }
                }
            }];
            
            if (indexSet.count > 1){
                NSRange firstRange = temps[indexSet.firstIndex].rangeValue;
                NSRange lastRange = temps[indexSet.lastIndex].rangeValue;
                NSInteger location = MIN(firstRange.location, range.location);
                NSInteger endOffset = MAX(lastRange.location + lastRange.length, range.location + range.length);
                NSRange combineRange = NSMakeRange(location, endOffset - location);
                [temps removeObjectsAtIndexes:indexSet];
                [temps insertObject:[NSValue valueWithRange:combineRange] atIndex:indexSet.firstIndex];
            }else if (indexSet.count == 1){
                NSRange firstRange = temps[indexSet.firstIndex].rangeValue;
                NSRange expandFirstRange = NSMakeRange(firstRange.location, firstRange.length + 1);
                NSRange expandFragmentRange = NSMakeRange(range.location, range.length + 1);
                NSRange intersectionRange = NSIntersectionRange(expandFirstRange, expandFragmentRange);
                if (intersectionRange.length > 0){
                    NSInteger location  = MIN(firstRange.location, range.location);
                    NSInteger endOffset = MAX(firstRange.location + firstRange.length, range.location + range.length);
                    NSRange combineRange = NSMakeRange(location, endOffset - location);
                    [temps removeObjectAtIndex:indexSet.firstIndex];
                    [temps insertObject:[NSValue valueWithRange:combineRange] atIndex:indexSet.firstIndex];
                }else{
                    if (firstRange.location > range.location){
                        [temps insertObject:[NSValue valueWithRange:range] atIndex:indexSet.lastIndex];
                    }else{
                        [temps insertObject:[NSValue valueWithRange:range] atIndex:indexSet.lastIndex+1];
                    }
                }
            }
        }
        self.cacheFragments = temps.mutableCopy;
    }
}
- (void)kj_downloadedBytes:(int64_t)bytes spentTime:(NSTimeInterval)time{
    @synchronized (self.downloadInfo){
        self.downloadInfo = [self.downloadInfo arrayByAddingObject:@[@(bytes), @(time)]];
    }
}

@end
