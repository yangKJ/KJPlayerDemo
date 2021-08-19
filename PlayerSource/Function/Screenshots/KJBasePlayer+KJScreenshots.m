//
//  KJBasePlayer+KJScreenshots.m
//  KJPlayer
//
//  Created by 77。 on 2021/8/19.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJBasePlayer+KJScreenshots.h"

@implementation KJBasePlayer (KJScreenshots)

/// 截图
/// @param source 内核名
/// @param object 参数
/// @param object2 参数
/// @param withBlock 响应回调
- (void)kj_screenshotsIMP:(NSString *)source
                   object:(id)object
              otherObject:(id)object2
                withBlock:(KJPlayerAnyBlock)withBlock{
    
}

//- (void (^)(void (^)(UIImage *)))kVideoTimeScreenshots{
//    return ^(void (^xxblock)(UIImage *)){
//        kGCD_player_async(^{
//            KJPlayerAssetType type = kPlayerVideoAesstType(self.originalURL);
//            if (type == KJPlayerAssetTypeNONE) {
//                kGCD_player_main(^{
//                    if (xxblock) xxblock(nil);
//                });
//            } else if (type == KJPlayerAssetTypeHLS) {
//                CVPixelBufferRef pixelBuffer = [self.playerOutput copyPixelBufferForItemTime:self.player.currentTime itemTimeForDisplay:nil];
//                CIImage *ciImage = [CIImage imageWithCVPixelBuffer:pixelBuffer];
//                CIContext *temporaryContext = [CIContext contextWithOptions:nil];
//                CGImageRef imageRef = [temporaryContext createCGImage:ciImage fromRect:CGRectMake(0, 0, CVPixelBufferGetWidth(pixelBuffer), CVPixelBufferGetHeight(pixelBuffer))];
//                UIImage *newImage = [UIImage imageWithCGImage:imageRef];
//                kGCD_player_main(^{
//                    if (xxblock) xxblock(newImage);
//                });
//                CGImageRelease(imageRef);
//                CVBufferRelease(pixelBuffer);
//            } else {
//                CGImageRef imageRef = [self.imageGenerator copyCGImageAtTime:self.player.currentTime actualTime:NULL error:NULL];
//                UIImage *newImage = [[UIImage alloc] initWithCGImage:imageRef];
//                kGCD_player_main(^{
//                    if (xxblock) xxblock(newImage);
//                });
//                CGImageRelease(imageRef);
//            }
//        });
//    };
//}
//- (void (^)(void(^)(UIImage *image),NSURL *,NSTimeInterval))kVideoPlaceholderImage{
//    return ^(void(^xxblock)(UIImage*),NSURL *videoURL,NSTimeInterval time){
//        kGCD_player_async(^{
//            UIImage *image = [KJCacheManager kj_getVideoCoverImageWithURL:videoURL];
//            if (image) {
//                kGCD_player_main(^{
//                    if (xxblock) xxblock(image);
//                });
//                return;
//            }
//            AVURLAsset *asset = [AVURLAsset URLAssetWithURL:videoURL options:self.requestHeader];
//            if ([asset tracksWithMediaType:AVMediaTypeVideo].count == 0) {
//                kGCD_player_main(^{
//                    if (xxblock) xxblock(nil);
//                });
//            }
//            AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
//            generator.appliesPreferredTrackTransform = YES;
//            generator.requestedTimeToleranceAfter = kCMTimeZero;
//            generator.requestedTimeToleranceBefore = kCMTimeZero;
//            CGImageRef cgimage = [generator copyCGImageAtTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC) actualTime:nil error:nil];
//            UIImage *videoImage = [[UIImage alloc] initWithCGImage:cgimage];
//            kGCD_player_main(^{
//                if (xxblock) xxblock(videoImage);
//            });
//            [KJCacheManager kj_saveVideoCoverImage:videoImage VideoURL:videoURL];
//            CGImageRelease(cgimage);
//        });
//    };
//}

/// 获取当前时间截屏
/// @param screenshots 截屏回调
- (void)kj_currentTimeScreenshots:(void(^)(UIImage * image))screenshots{
    [self kj_appointTime:self.currentTime screenshots:screenshots];
}

/// 获取指定时间截屏
/// @param time 指定时间
/// @param screenshots 截屏回调
- (void)kj_appointTime:(NSTimeInterval)time screenshots:(void(^)(UIImage * image))screenshots{
    NSString * source = []
}

/// 子线程获取封面图，图片会存储在磁盘
/// @param time 时间节点
/// @param url 视频地址
/// @param placeholder 封面图
- (void)kj_placeholderImageWithTime:(NSTimeInterval)time
                           videoURL:(NSString *)url
                        placeholder:(void(^)(UIImage * image))placeholder{
    
}


#pragma mark - 封面图

#define kCacheImage \
[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject \
stringByAppendingPathComponent:@"videoImages"]

/// 存入视频封面图
+ (void)kj_saveVideoCoverImage:(UIImage *)image videoURL:(NSURL *)videoURL{
    NSData *data = UIImageJPEGRepresentation(image, 1.0);
    NSString *name = kPlayerMD5(videoURL.resourceSpecifier?:videoURL.absoluteString);
    NSString *directoryPath = kCacheImage;
    if (![[NSFileManager defaultManager] fileExistsAtPath:directoryPath isDirectory:nil]) {
        NSError *error = nil;
        BOOL isOK = [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath
                                              withIntermediateDirectories:YES
                                                               attributes:nil
                                                                    error:&error];
        if (isOK && error == nil) {} else return;
    }
    @autoreleasepool {
        NSString *path = [directoryPath stringByAppendingPathComponent:name];
        [[NSFileManager defaultManager] createFileAtPath:path contents:data attributes:nil];
    }
}
/// 读取视频封面图
+ (UIImage *)kj_getVideoCoverImageWithURL:(NSURL *)url{
    NSString *name = kPlayerMD5(url.resourceSpecifier?:url.absoluteString);
    NSData *data = [NSData dataWithContentsOfFile:[kCacheImage stringByAppendingPathComponent:name]];
    return [UIImage imageWithData:data];
}
/// 清除视频封面图
+ (void)kj_clearVideoCoverImageWithURL:(NSURL *)url{
    NSString *name = kPlayerMD5(url.resourceSpecifier?:url.absoluteString);
    NSString *directoryPath = [kCacheImage stringByAppendingPathComponent:name];
    if ([[NSFileManager defaultManager] fileExistsAtPath:directoryPath isDirectory:nil]) {
        [[NSFileManager defaultManager] removeItemAtPath:directoryPath error:nil];
    }
}
/// 清除全部封面缓存
+ (void)kj_clearAllVideoCoverImage{
    NSString *directoryPath = kCacheImage;
    if ([[NSFileManager defaultManager] fileExistsAtPath:directoryPath isDirectory:nil]) {
        [[NSFileManager defaultManager] removeItemAtPath:directoryPath error:nil];
    }
}

@end
