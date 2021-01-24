//
//  KJPlayerType.h
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/1/8.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo
//  枚举文件夹和公共方法

#ifndef KJPlayerType_h
#define KJPlayerType_h
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN
// vedio文件目录
#define DOCUMENTS_FOLDER_VEDIO  @"playerVedio"
// 弱引用
#define PLAYER_WEAKSELF __weak typeof(self) weakself = self
// 屏幕尺寸
#define PLAYER_SCREEN_WIDTH  ([UIScreen mainScreen].bounds.size.width)
#define PLAYER_SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
// 颜色
#define PLAYER_UIColorFromHEXA(hex,a) [UIColor colorWithRed:((hex&0xFF0000)>>16)/255.0f green:((hex&0xFF00)>>8)/255.0f blue:(hex&0xFF)/255.0f alpha:a]

/// 播放器的几种状态
typedef NS_ENUM(NSInteger, KJPlayerState) {
    KJPlayerStateLoading = 1, /// 加载中缓存数据
    KJPlayerStatePlaying = 2, /// 播放中
    KJPlayerStatePlayEnd = 3, /// 播放结束
    KJPlayerStateStopped = 4, /// 停止
    KJPlayerStatePause   = 5, /// 暂停
    KJPlayerStateError   = 6, /// 播放错误
};
/// 播放状态
static NSString * const _Nonnull KJPlayerStateStringMap[] = {
    [KJPlayerStateLoading] = @"loading",
    [KJPlayerStatePlaying] = @"playing",
    [KJPlayerStatePlayEnd] = @"end",
    [KJPlayerStateStopped] = @"stop",
    [KJPlayerStatePause]   = @"pause",
    [KJPlayerStateError]   = @"error",
};
/// 几种错误的code
typedef NS_ENUM(NSInteger, KJPlayerErrorCode) {
    KJPlayerErrorCodeNoError = 0, /// 正常播放
    KJPlayerErrorCodeOtherSituations = 1, /// 其他情况
    KJPlayerErrorCodeVideoUrlError = 100, /// 视频地址不正确
    KJPlayerErrorCodeNetworkOvertime = -1001, /// 请求超时：-1001
    KJPlayerErrorCodeServerNotFound  = -1003, /// 找不到服务器：-1003
    KJPlayerErrorCodeServerInternalError = -1004, /// 服务器内部错误：-1004
    KJPlayerErrorCodeNetworkInterruption = -1005, /// 网络中断：-1005
    KJPlayerErrorCodeNetworkNoConnection = -1009, /// 无网络连接：-1009
};
/// 缓存状态
typedef NS_ENUM(NSInteger, KJPlayerLoadState) {
    KJPlayerLoadStateNone = 0,/// 没有缓存
    KJPlayerLoadStateLoading, /// 缓存数据中
    KJPlayerLoadStateComplete,/// 缓存结束
    KJPlayerLoadStateError,   /// 缓存失败
    KJPlayerLoadStateSaveSuccess, /// 缓存成功
};
/// 手势操作的类型
typedef NS_ENUM(NSUInteger, KJPlayerGestureType) {
    KJPlayerGestureTypeProgress = 0, //视频进度调节操作
    KJPlayerGestureTypeVoice    = 1, //声音调节操作
    KJPlayerGestureTypeLight    = 2, //屏幕亮度调节操作
    KJPlayerGestureTypeNone     = 3, //无任何操作
};
/// 播放类型
typedef NS_ENUM(NSUInteger, KJPlayerPlayType) {
    KJPlayerPlayTypeReplay = 0, //重复播放
    KJPlayerPlayTypeOrder  = 1, //顺序播放
    KJPlayerPlayTypeRandom = 2, //随机播放
    KJPlayerPlayTypeOnce   = 3, //仅播放一次
};
/// 手机方向
typedef NS_ENUM(NSUInteger, KJPlayerDeviceDirection) {
    KJPlayerDeviceDirectionCustom,//其他
    KJPlayerDeviceDirectionTop,   //上
    KJPlayerDeviceDirectionBottom,//下
    KJPlayerDeviceDirectionLeft,  //左
    KJPlayerDeviceDirectionRight, //右
};
typedef void (^KJPlayerSeekBeginPlayBlock)(void);

// 判断是否含有视频轨道
NS_INLINE bool kPlayerHaveTracks(NSURL *url){
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    return [tracks count] > 0;
}
// 判断是否是URL，谓词方式
NS_INLINE bool kPlayerURLUsable(NSURL *url){
    if(url == nil) return false;
    NSString *string = [url absoluteString];
    NSString *regex = @"(https|http|ftp|rtsp|igmp|file|rtspt|rtspu)://((((25[0-5]|2[0-4]\\d|1?\\d?\\d)\\.){3}(25[0-5]|2[0-4]\\d|1?\\d?\\d))|([0-9a-z_!~*'()-]*\\.?))([0-9a-z][0-9a-z-]{0,61})?[0-9a-z]\\.([a-z]{2,6})(:[0-9]{1,4})?([a-zA-Z/?_=]*)\\.\\w{1,5}";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [predicate evaluateWithObject:string];
}
// 判断当前URL是否可用，信号量方式
NS_INLINE bool kPlayerValidate(NSURL *url){
    __block BOOL boo = false;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    dispatch_group_async(dispatch_group_create(), queue, ^{
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [request setHTTPMethod:@"HEAD"];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        [[session dataTaskWithRequest:request completionHandler:^(NSData*data,NSURLResponse*response,NSError*error) {
            boo = error ? false : true;
            dispatch_semaphore_signal(sem);
        }] resume];
    });
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    return boo;
}
// MD5加密
NS_INLINE NSString * kPlayerMD5(NSString *string){
    const char *str = [string UTF8String];
    unsigned char digist[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (uint)strlen(str), digist);
    NSMutableString *outPutStr = [NSMutableString stringWithCapacity:10];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++){
        [outPutStr appendFormat:@"%02X", digist[i]];
    }
    return [outPutStr lowercaseString];
}
// 得到完整路径
NS_INLINE NSString * kPlayerIntactPath(NSURL *url){
    NSString *urlString = [url absoluteString];
    NSArray  *array = [urlString componentsSeparatedByString:@"://"];
    NSString *name = array.count > 1 ? array[1] : urlString;
    NSString *videoName = [kPlayerMD5(name) stringByAppendingString:@".mp4"];
    NSString *document = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES).lastObject;
    NSString *filePath = [document stringByAppendingPathComponent:videoName];
    return filePath;
}
// 获取当前的旋转状态
NS_INLINE CGAffineTransform kPlayerDeviceOrientation(void){
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation == UIInterfaceOrientationPortrait) {
        return CGAffineTransformIdentity;
    }else if (orientation == UIInterfaceOrientationLandscapeLeft) {
        return CGAffineTransformMakeRotation(-M_PI_2);
    }else if (orientation == UIInterfaceOrientationLandscapeRight) {
        return CGAffineTransformMakeRotation(M_PI_2);
    }
    return CGAffineTransformIdentity;
}
// 设置时间显示
NS_INLINE NSString * kPlayerConvertTime(CGFloat second){
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    if (second / 3600 >= 1) {
        [dateFormatter setDateFormat:@"HH:mm:ss"];
    }else{
        [dateFormatter setDateFormat:@"mm:ss"];
    }
    return [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:second]];
}

#endif /* KJPlayerType_h */

NS_ASSUME_NONNULL_END
