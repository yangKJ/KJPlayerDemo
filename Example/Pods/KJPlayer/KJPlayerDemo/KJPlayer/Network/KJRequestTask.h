//
//  KJRequestTask.h
//  KJPlayerDemo
//
//  Created by 杨科军 on 2019/7/20.
//  Copyright © 2019 杨科军. All rights reserved.
//
/** KJRequestTask 主要功能：
 *  网络请求数据，并把数据写入到 NSDocumentDirectory（临时文件）
 *  网络请求结束的时候，
 *  如果数据完整，则把数据缓存到指定的路径，储存起来
 *  如果不完整，则删除缓存的临时文件数据
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KJRequestTask : NSObject
@property (nonatomic,strong,readonly) NSURL *url;/// 视频地址
@property (nonatomic,assign,readonly) NSUInteger currentOffset; /// 当前偏移量
@property (nonatomic,assign,readonly) NSUInteger downLoadOffset;/// 下载偏移量
@property (nonatomic,assign,readonly) NSUInteger videoLength;/// 视频长度
@property (nonatomic,assign,readonly) BOOL completeLoad; /// 是否下载完成

/* 开始下载 */
- (void)kj_startLoadWithUrl:(NSURL*)url Offset:(NSUInteger)offset;
/* 取消网络请求 */
- (void)kj_cancelLoading;
/* 继续网络下载 */
- (void)kj_continueLoading;
/* 清除临时缓存 */
- (void)kj_clearCurrentLoadDatas;

/************************* 事件处理 *************************/
/** 当接收到服务器响应的时候调用 返回视频长度 videoLength */
@property (nonatomic,copy) void (^kRequestTaskDidReceiveVideoLengthBlcok)(KJRequestTask *task, NSUInteger videoLength);
/** 当接收到数据的时候调用，该方法会被调用多次 返回接收到的服务端二进制数据 NSData */
@property (nonatomic,copy) void (^kRequestTaskDidReceiveDataBlcok)(KJRequestTask *task, NSData *data);
/** 当服务端返回的数据接收完毕之后会调用 */
@property (nonatomic,copy) void (^kRequestTaskDidFinishLoadingAndSaveFileBlcok)(KJRequestTask *task, BOOL saveSuccess);
/** 当请求错误的时候调用
 *  errorCode 对应的一些code
 *  请求超时：-1001
 *  找不到服务器：-1003
 *  服务器内部错误：-1004
 *  网络中断：-1005
 *  无网络连接：-1009
 */
@property (nonatomic,copy) void (^kRequestTaskdidFailWithErrorCodeBlcok)(KJRequestTask *task, NSInteger errorCode);

@end

NS_ASSUME_NONNULL_END
