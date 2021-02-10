//
//  KJRequestTask.h
//  KJPlayerDemo
//
//  Created by 杨科军 on 2019/7/20.
//  Copyright © 2019 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo
/*  KJRequestTask 主要功能：
 *  网络请求数据，并把数据写入到 NSDocumentDirectory（临时文件）
 *  网络请求结束的时候，
 *  如果数据完整，则把数据缓存到指定的路径，储存起来
 *  如果不完整，则删除缓存的临时文件数据
 */

#import <Foundation/Foundation.h>
#import "KJPlayerType.h"
NS_ASSUME_NONNULL_BEGIN

@interface KJRequestTask : NSObject
/* 文件名 */
@property (nonatomic,strong) NSString *fileName;
/* 存储路径地址 */
@property (nonatomic,strong) NSString *savePath;
/* 临时文件完整路径 */
@property (nonatomic,strong,readonly) NSString *tempPath;
/* 当前偏移量 */
@property (nonatomic,assign,readonly) NSUInteger currentOffset;
/* 下载偏移量 */
@property (nonatomic,assign,readonly) NSUInteger downLoadOffset;
/* 总偏移量 */
@property (nonatomic,assign,readonly) NSUInteger totalOffset;
/* 初始化文件格式，默认.mp4 */
- (instancetype)kj_initWithFlieFormat:(NSString*)format;
/* 开始下载 */
- (void)kj_startLoadWithUrl:(NSURL*)url Offset:(NSUInteger)offset;
/* 取消网络请求 */
- (void)kj_cancelLoading;
/* 继续网络下载 */
- (void)kj_continueLoading;
/* 清除临时缓存 */
- (void)kj_clearTempLoadDatas;

@end
/* *********************** 事件处理 *************************/
@interface KJRequestTask (KJRequestTaskBlock)
/* 当接收到数据的时候调用，该方法会被调用多次 返回接收到的服务端二进制数据 NSData */
@property (nonatomic,copy,readwrite) void (^kRequestTaskReceiveDataBlcok)(KJRequestTask *task, NSData *data);
/* 当服务端返回的数据接收完毕之后会调用 */
@property (nonatomic,copy,readwrite) void (^kRequestTaskSaveBlock)(KJRequestTask *task, BOOL saveSuccess);
/*  当请求错误的时候调用 */
@property (nonatomic,copy,readwrite) void (^kRequestTaskFailedBlcok)(KJRequestTask *task, NSInteger errorCode);

@end

NS_ASSUME_NONNULL_END
