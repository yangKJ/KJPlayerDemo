//
//  KJFileOperation.h
//  KJPlayerDemo
//
//  Created by 杨科军 on 2019/7/27.
//  Copyright © 2019 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo
//  文件操作 新建文件夹 删除文件夹下的所有文件

#ifndef KJFileOperation_h
#define KJFileOperation_h
#import <Foundation/Foundation.h>

//根据时间得到随机文件名
NS_INLINE NSString * kPlayerRandomFilesName(void){
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmssSSS";
    return [formatter stringFromDate:[NSDate date]];
}
//判断存放视频的文件夹是否存在，不存在则创建对应文件夹
NS_INLINE BOOL kPlayerNewFile(NSString * path){
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
//删除文件夹下的所有文件
NS_INLINE BOOL kPlayerRemoveAllFile(NSString * path){
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[NSTemporaryDirectory() stringByAppendingPathComponent:path] error:NULL];
    NSEnumerator *e = [contents objectEnumerator];
    NSString *filename;
    while ((filename = [e nextObject])) {
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

#endif /* KJFileOperation_h */
