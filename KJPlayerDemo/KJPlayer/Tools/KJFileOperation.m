//
//  KJFileOperation.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2019/7/27.
//  Copyright © 2019 杨科军. All rights reserved.
//  

#import "KJFileOperation.h"

@implementation KJFileOperation

// 判断存放视频的文件夹是否存在，不存在则创建对应文件夹
+ (BOOL)kj_fileNewFileWithPath:(NSString *)path{
    NSMutableString *string = [[NSMutableString alloc] init];
    [string setString:path];
    CFStringTrimWhitespace((CFMutableStringRef)string);
    if([string length] == 0){
        return NO;
    }
    NSString *finalPath = [NSTemporaryDirectory() stringByAppendingPathComponent:path];
    //判断文件是否存在
    if (![[NSFileManager defaultManager] fileExistsAtPath:finalPath]) {//如果文件不存在则创建
        //创建子文件
        //NSString *fileDirectory = [NSString stringWithFormat:@"%@.txt",@"filename"];
        //NSString *systempath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",fileName]];
        BOOL boo = [[NSFileManager defaultManager] createDirectoryAtPath:finalPath withIntermediateDirectories:YES attributes:nil error:nil];
        NSAssert(boo,@"创建目录失败");
        return boo;
    }
    return YES;
}
// 删除文件夹下的所有文件
+ (BOOL)kj_fileRemoveWithPath:(NSString *)path{
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[NSTemporaryDirectory() stringByAppendingPathComponent:path] error:NULL];
    NSEnumerator *e = [contents objectEnumerator];
    NSString *filename;
    while ((filename = [e nextObject])) {
        [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/%@/%@",NSTemporaryDirectory(),path,filename] error:NULL];
    }
    return YES;
}
//删除文件
+ (BOOL)kj_fileRemoveFileWithPath:(NSString *)path{
    if([self kj_fileIsFileExistWithPath:path] != nil){
        NSString *loc_path = [NSString stringWithFormat:@"%@/%@",NSTemporaryDirectory(),path];
        NSLog(@"删除路径:%@",loc_path);
        [[NSFileManager defaultManager] removeItemAtPath:loc_path error:NULL];
        return YES;
    }
    return NO;
}
// 判断文件是否存在 存在返回文件路径
+ (NSString *)kj_fileIsFileExistWithPath:(NSString *)path{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    if([fileManager fileExistsAtPath:[NSTemporaryDirectory() stringByAppendingPathComponent:path]]){
        return [NSTemporaryDirectory() stringByAppendingPathComponent:path];
    }
    return nil;
}
// 随机文件名
+ (NSString *)randomFilesName{
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    NSDate *date = [NSDate date];
    fmt.dateFormat = @"yyyyMMddHHmmssSSS"; // @"yyyy-MM-dd HH:mm:ss"
    NSString *time = [fmt stringFromDate:date];
    return time;
}

@end
