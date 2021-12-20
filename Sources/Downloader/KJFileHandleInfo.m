//
//  KJFileHandleInfo.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/10.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJFileHandleInfo.h"
#import <objc/runtime.h>
#import "KJDownloaderCommon.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"

@interface KJFileHandleInfo ()
@property (nonatomic,strong) NSArray *cacheFragments;
@property (nonatomic,strong) NSString *fileName;
@property (nonatomic,strong) NSString *fileFormat;
@property (nonatomic,strong) NSURL *videoURL;

@end

@implementation KJFileHandleInfo

#pragma mark - NSCopying

- (id)copyWithZone:(nullable NSZone *)zone {
    KJFileHandleInfo *info = [[[self class] allocWithZone:zone] init];
    unsigned int count = 0;
    Ivar *ivars = class_copyIvarList([self class], &count);
    for (int i = 0; i<count; i++) {
        const char *name = ivar_getName(ivars[i]);
        NSString *key = [NSString stringWithUTF8String:name];
        id value = [self valueForKey:key];
        if ([value respondsToSelector:@selector(copyWithZone:)]) {
            [info setValue:[value copy] forKey:key];
        } else {
            [info setValue:value forKey:key];
        }
    }
    free(ivars);
    return info;
}
/// 归档 
- (void)encodeWithCoder:(NSCoder *)aCoder{
    unsigned int count = 0;
    Ivar *ivars = class_copyIvarList([self class], &count);
    for (int i = 0; i<count; i++) {
        const char *name = ivar_getName(ivars[i]);
        NSString *key = [NSString stringWithUTF8String:name];
        id value = [self valueForKey:key];
        [aCoder encodeObject:value forKey:key];
    }
    free(ivars);
}
/// 解档 
- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]) {
        unsigned int count = 0;
        Ivar *ivars = class_copyIvarList([self class], &count);
        for (int i = 0; i<count; i++) {
            const char *name = ivar_getName(ivars[i]);
            NSString *key = [NSString stringWithUTF8String:name];
            id value = [aDecoder decodeObjectForKey:key];
            [self setValue:value forKey:key];
        }
        free(ivars);
    }
    return self;
}
+ (instancetype)kj_createFileHandleInfoWithURL:(NSURL *)url{
    NSString * path = [KJFileHandleInfo kj_appendingVideoTempPath:url];
    KJFileHandleInfo *info = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    if (info == nil) info = [[KJFileHandleInfo alloc] init];
    info.videoURL = url;
    info.fileName = kMD5FileNameFormVideoURL(url);
    info.fileFormat = url.pathExtension;
    return info;
}
- (float)progress{
    return self.downloadedBytes / (float)self.contentLength;
}
- (int64_t)downloadedBytes{
    float bytes = 0;
    @synchronized (self.cacheFragments) {
        for (NSValue *range in self.cacheFragments) {
            bytes += range.rangeValue.length;
        }
    }
    return bytes;
}
- (void)kj_keyedArchiverSave{
    @synchronized (self.cacheFragments) {
        NSString * path = [KJFileHandleInfo kj_appendingVideoTempPath:self.videoURL];
        [NSKeyedArchiver archiveRootObject:self toFile:path];
    }
}
- (void)kj_continueCacheFragmentRange:(NSRange)range{
    if (range.location == NSNotFound || range.length == 0) {
        return;
    }
    @synchronized (self.cacheFragments) {
        NSMutableArray<NSValue*>*temps = [NSMutableArray arrayWithArray:self.cacheFragments];
        NSInteger count = temps.count;
        if (count == 0) {
            [temps addObject:[NSValue valueWithRange:range]];
        } else {
            NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
            [temps enumerateObjectsUsingBlock:^(NSValue *obj, NSUInteger idx, BOOL *stop) {
                NSRange ran = obj.rangeValue;
                if ((range.location + range.length) <= ran.location) {
                    if (indexSet.count == 0) {
                        [indexSet addIndex:idx];
                    }
                    *stop = YES;
                } else if (range.location <= (ran.location + ran.length) &&
                          (range.location + range.length) > ran.location) {
                    [indexSet addIndex:idx];
                } else if (range.location >= ran.location + ran.length) {
                    if (idx == count - 1) {
                        [indexSet addIndex:idx];
                    }
                }
            }];
            
            if (indexSet.count > 1) {
                NSRange firstRange = temps[indexSet.firstIndex].rangeValue;
                NSRange lastRange = temps[indexSet.lastIndex].rangeValue;
                NSInteger location = MIN(firstRange.location, range.location);
                NSInteger endOffset = MAX(lastRange.location + lastRange.length, range.location + range.length);
                NSRange combineRange = NSMakeRange(location, endOffset - location);
                [temps removeObjectsAtIndexes:indexSet];
                [temps insertObject:[NSValue valueWithRange:combineRange] atIndex:indexSet.firstIndex];
            } else if (indexSet.count == 1) {
                NSRange firstRange = temps[indexSet.firstIndex].rangeValue;
                NSRange expandFirstRange = NSMakeRange(firstRange.location, firstRange.length + 1);
                NSRange expandFragmentRange = NSMakeRange(range.location, range.length + 1);
                NSRange intersectionRange = NSIntersectionRange(expandFirstRange, expandFragmentRange);
                if (intersectionRange.length > 0) {
                    NSInteger location  = MIN(firstRange.location, range.location);
                    NSInteger endOffset = MAX(firstRange.location + firstRange.length, range.location + range.length);
                    NSRange combineRange = NSMakeRange(location, endOffset - location);
                    [temps removeObjectAtIndex:indexSet.firstIndex];
                    [temps insertObject:[NSValue valueWithRange:combineRange] atIndex:indexSet.firstIndex];
                } else {
                    if (firstRange.location > range.location) {
                        [temps insertObject:[NSValue valueWithRange:range] atIndex:indexSet.lastIndex];
                    } else {
                        [temps insertObject:[NSValue valueWithRange:range] atIndex:indexSet.lastIndex+1];
                    }
                }
            }
        }
        self.cacheFragments = temps.mutableCopy;
    }
}

#pragma mark - 结构体相关

/// 缓存碎片结构体转对象
+ (NSValue *)kj_cacheFragment:(KJCacheFragment)fragment{
    return [NSValue valueWithBytes:&fragment objCType:@encode(struct KJCacheFragment)];
}
/// 缓存碎片对象转结构体
+ (KJCacheFragment)kj_getCacheFragment:(id)obj{
    KJCacheFragment fragment;
    [obj getValue:&fragment];
    return fragment;
}

#pragma mark - NSFileManager

/// 创建文件夹
+ (BOOL)kj_createFilePath:(NSString *)path{
    NSError * error = nil;
    NSString *cacheFolder = [path stringByDeletingLastPathComponent];
    if (![[NSFileManager defaultManager] fileExistsAtPath:cacheFolder]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:cacheFolder
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&error];
    } else {
        return NO;
    }
    return error == nil ? YES : NO;
}

#pragma mark - Sandbox板块

/// 创建缓存文件完整路径
+ (NSString *)kj_createVideoCachedPath:(NSURL *)url{
    NSString *pathComponent = kMD5FileNameFormVideoURL(url);
    pathComponent = [pathComponent stringByAppendingPathExtension:url.pathExtension];
    return [PLAYER_CACHE_VIDEO_DIRECTORY stringByAppendingPathComponent:pathComponent];
}
/// 追加临时缓存路径，用于播放器读取
+ (NSString *)kj_appendingVideoTempPath:(NSURL *)url{
    return [[self kj_createVideoCachedPath:url] stringByAppendingPathExtension:PLAYER_TEMP_READ_NAME];
}

@end

#pragma clang diagnostic pop
