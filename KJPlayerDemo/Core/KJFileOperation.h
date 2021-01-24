//
//  KJFileOperation.h
//  KJPlayerDemo
//
//  Created by 杨科军 on 2019/7/27.
//  Copyright © 2019 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo
//  文件操作 新建文件夹 删除文件夹下的所有文件

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KJFileOperation : NSObject
/// 判断存放视频的文件夹是否存在，不存在则创建对应文件夹
+ (BOOL)kj_fileNewFileWithPath:(NSString*)path;
/// 删除文件夹下的所有文件
+ (BOOL)kj_fileRemoveWithPath:(NSString*)path;
/// 删除文件
+ (BOOL)kj_fileRemoveFileWithPath:(NSString*)path;
/// 判断文件是否存在 存在返回文件路径
+ (NSString*)kj_fileIsFileExistWithPath:(NSString*)path;
/// 随机文件名
+ (NSString*)kj_randomFilesName;

@end

NS_ASSUME_NONNULL_END
