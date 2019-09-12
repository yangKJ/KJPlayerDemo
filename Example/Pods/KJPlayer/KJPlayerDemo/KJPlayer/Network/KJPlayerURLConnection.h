//
//  KJPlayerURLConnection.h
//  KJPlayerDemo
//
//  Created by 杨科军 on 2019/7/20.
//  Copyright © 2019 杨科军. All rights reserved.
//
/** KJPlayerURLConnection 主要功能：
 *  把网络请求缓存到本地的临时数据 offset 和 videoLength 传递给播放器
 */

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

///
FOUNDATION_EXPORT NSString *const kMIMEType;
@interface KJPlayerURLConnection : NSURLConnection<AVAssetResourceLoaderDelegate>

- (NSURL*)kSetComponentsWithUrl:(NSURL*)url;

/************************* 事件处理 *************************/
/** 当服务端返回的数据接收完毕之后会调用 */
@property (nonatomic,copy) void (^kPlayerURLConnectionDidFinishLoadingAndSaveFileBlcok)(BOOL completeLoad, BOOL saveSuccess);
/** 当请求错误的时候调用 */
@property (nonatomic,copy) void (^kPlayerURLConnectiondidFailWithErrorCodeBlcok)(NSInteger errorCode);

@end

NS_ASSUME_NONNULL_END
