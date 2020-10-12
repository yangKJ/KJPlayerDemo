//
//  KJPlayerTool.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2019/7/21.
//  Copyright © 2019 杨科军. All rights reserved.
//

#import "KJPlayerTool.h"
#import "KJFileOperation.h"
#import <CommonCrypto/CommonDigest.h>
#import <AVFoundation/AVFoundation.h>

//#define DOCUMENTS_FOLDER_AUDIO @"audio" //你定义的audio对应的文件目录
#define DOCUMENTS_FOLDER_VEDIO  @"playerVedio" //你定义的vedio对应的文件目录

@implementation KJPlayerTool

/// 判断是否含有视频轨道
+ (BOOL)kj_playerHaveTracksWithURL:(NSURL*)url{
    //1.判断是否含有视频轨道（判断视频是否可以正常播放）
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    BOOL hasVideoTrack = [tracks count] > 0;
    return hasVideoTrack;
}

/// 判断是否是URL
+ (BOOL)kj_playerIsURL:(NSURL*)url{
    if(url == nil) return NO;
    NSString *string = [url absoluteString];
    NSString *urlRegex = @"(https|http|ftp|rtsp|igmp|file|rtspt|rtspu)://((((25[0-5]|2[0-4]\\d|1?\\d?\\d)\\.){3}(25[0-5]|2[0-4]\\d|1?\\d?\\d))|([0-9a-z_!~*'()-]*\\.?))([0-9a-z][0-9a-z-]{0,61})?[0-9a-z]\\.([a-z]{2,6})(:[0-9]{1,4})?([a-zA-Z/?_=]*)\\.\\w{1,5}";
    /// 谓词判断
    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegex];
    return [urlTest evaluateWithObject:string];
}

/// Block 同步执行 判断当前URL是否可用
+ (BOOL)kj_playerValidateUrl:(NSURL*)url{
    __block BOOL boo = NO;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);//创建信号量初始值为0  0:表示无限等待
    dispatch_group_async(dispatch_group_create(), queue, ^{
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [request setHTTPMethod:@"HEAD"];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            boo = error ? NO : YES;
            dispatch_semaphore_signal(sem); //发送信号量 信号量+1
        }] resume];
    });
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);//阻塞等待 信号量-1
    return boo;
}

/// md5加密
+ (NSString*)kj_playerMD5WithString:(NSString*)string{
    const char *original_str = [string UTF8String];
    unsigned char digist[CC_MD5_DIGEST_LENGTH]; // CC_MD5_DIGEST_LENGTH = 16
    CC_MD5(original_str, (uint)strlen(original_str), digist);
    NSMutableString *outPutStr = [NSMutableString stringWithCapacity:10];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++){
        [outPutStr appendFormat:@"%02X", digist[i]];//小写x表示输出的是小写MD5，大写X表示输出的是大写MD5
    }
    return [outPutStr lowercaseString];
}

/// 根据 url 得到完整路径
+ (NSString*)kj_playerGetIntegrityPathWithUrl:(NSURL*)url{
    NSString *document = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
//    NSString *videoPath = [document stringByAppendingPathComponent:DOCUMENTS_FOLDER_VEDIO];
//    // 判断存放音频、视频的文件夹是否存在，不存在则创建对应文件夹
//    BOOL boo = [KJFileOperation kj_fileNewFileWithPath:videoPath];
//    if (boo == NO) return nil;
    NSString *urlString = [url absoluteString];
    /// 分割字符串
    NSArray *array = [urlString componentsSeparatedByString:@"://"];
    NSString *name = array.count > 1 ? array[1] : urlString; /// 去掉 :// 之前的数据
    /// 加密名字
    NSString *md5Name = [self kj_playerMD5WithString:name];
    NSString *videoName = [md5Name stringByAppendingString:@".mp4"];
    NSString *filePath = [document stringByAppendingPathComponent:videoName];
    return filePath;
}

// 获取视频第一帧图片
+ (UIImage*)kj_playerFristImageWithURL:(NSURL*)url{
    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:url options:opts];
    AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:urlAsset];
    generator.appliesPreferredTrackTransform = YES;
//    generator.maximumSize = CGSizeMake(size.width, size.height);
    NSError *error = nil;
    CGImageRef image = [generator copyCGImageAtTime:CMTimeMake(0, 10) actualTime:NULL error:&error];
    UIImage *videoImage = [UIImage imageWithCGImage:image];
    CGImageRelease(image);
    return videoImage;
}
    
// 获取视频总时间
+ (NSInteger)kj_playerVideoTotalTimeWithURL:(NSURL*)url{
    NSDictionary *opts = [NSDictionary dictionaryWithObject:@(NO) forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:opts];
    NSInteger seconds = ceil(asset.duration.value / asset.duration.timescale);
    return seconds;
}

// 获取当前的旋转状态
+ (CGAffineTransform)kj_playerCurrentDeviceOrientation{
    //状态条的方向已经设置过,所以这个就是你想要旋转的方向
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    //根据要进行旋转的方向来计算旋转的角度
    if (orientation == UIInterfaceOrientationPortrait) {
        return CGAffineTransformIdentity;
    }else if (orientation == UIInterfaceOrientationLandscapeLeft) {
        return CGAffineTransformMakeRotation(-M_PI_2);
    }else if (orientation == UIInterfaceOrientationLandscapeRight) {
        return CGAffineTransformMakeRotation(M_PI_2);
    }
    return CGAffineTransformIdentity;
}

/// 设置时间显示
+ (NSString *)kj_playerConvertTime:(CGFloat)second{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:second];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    if (second / 3600 >= 1) {
        [dateFormatter setDateFormat:@"HH:mm:ss"];
    }else {
        [dateFormatter setDateFormat:@"mm:ss"];
    }
    return [dateFormatter stringFromDate:date];
}

@end
