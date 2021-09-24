//
//  KJScreenshotsManager.m
//  KJPlayer
//
//  Created by 77。 on 2021/8/19.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJScreenshotsManager.h"
#import <CommonCrypto/CommonDigest.h>
#import "KJBasePlayer.h"
#import "KJPlayerConst.h"

@implementation KJScreenshotsManager

/// 截图
/// @param basePlayer 内核
/// @param object 参数
/// @param object2 参数
/// @param withBlock 响应回调
- (void)kj_screenshotsIMP:(__kindof KJBasePlayer *)basePlayer
                   object:(id)object
              otherObject:(id)object2
                withBlock:(void(^)(UIImage *))withBlock{
    NSString * source = NSStringFromClass([basePlayer class]);
    if ([source isEqualToString:@"KJAVPlayer"]) {
        [self kj_AVPlayerWithBasePlayer:basePlayer playerOutput:object imageGenerator:object2 withBlock:withBlock];
    }
}

- (void)kj_AVPlayerWithBasePlayer:(__kindof KJBasePlayer *)basePlayer
                     playerOutput:(AVPlayerItemVideoOutput *)playerOutput
                   imageGenerator:(AVAssetImageGenerator *)imageGenerator
                        withBlock:(void(^)(UIImage *))withBlock{
    kGCD_player_async(^{
        KJPlayerAssetType type = kPlayerVideoAesstType(basePlayer.originalURL);
        if (type == KJPlayerAssetTypeNONE) {
            kGCD_player_main(^{
                if (withBlock) withBlock(nil);
            });
            return;
        }
        NSTimeInterval currentTime = [[basePlayer valueForKey:@"currentTime"] doubleValue];
        CMTime itemTime = CMTimeMakeWithSeconds(currentTime, NSEC_PER_SEC);
        if (type == KJPlayerAssetTypeHLS) {
            CVPixelBufferRef pixelBuffer = [playerOutput copyPixelBufferForItemTime:itemTime itemTimeForDisplay:nil];
            CIImage *ciImage = [CIImage imageWithCVPixelBuffer:pixelBuffer];
            CIContext *temporaryContext = [CIContext contextWithOptions:nil];
            CGImageRef imageRef = [temporaryContext createCGImage:ciImage fromRect:CGRectMake(0, 0, CVPixelBufferGetWidth(pixelBuffer), CVPixelBufferGetHeight(pixelBuffer))];
            UIImage *newImage = [UIImage imageWithCGImage:imageRef];
            kGCD_player_main(^{
                if (withBlock) withBlock(newImage);
            });
            CGImageRelease(imageRef);
            CVBufferRelease(pixelBuffer);
        } else {
            CGImageRef imageRef = [imageGenerator copyCGImageAtTime:itemTime actualTime:NULL error:NULL];
            UIImage *newImage = [[UIImage alloc] initWithCGImage:imageRef];
            kGCD_player_main(^{
                if (withBlock) withBlock(newImage);
            });
            CGImageRelease(imageRef);
        }
    });
}

/// 子线程获取封面图，图片会存储在磁盘
/// @param time 时间节点
/// @param url 视频地址
/// @param placeholder 封面图
+ (void)kj_placeholderImageWithTime:(NSTimeInterval)time
                                url:(NSString *)url
                        placeholder:(void(^)(UIImage * image))placeholder{
    NSURL * videoURL = [NSURL URLWithString:url];
    kGCD_player_async(^{
        UIImage *image = [KJScreenshotsManager kj_getVideoCoverImageWithURL:videoURL];
        if (image) {
            kGCD_player_main(^{
                if (placeholder) placeholder(image);
            });
            return;
        }
        AVURLAsset *asset = [AVURLAsset URLAssetWithURL:videoURL options:nil];
        if ([asset tracksWithMediaType:AVMediaTypeVideo].count == 0) {
            kGCD_player_main(^{
                if (placeholder) placeholder(nil);
            });
        }
        AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        generator.appliesPreferredTrackTransform = YES;
        generator.requestedTimeToleranceAfter = kCMTimeZero;
        generator.requestedTimeToleranceBefore = kCMTimeZero;
        CGImageRef cgimage = [generator copyCGImageAtTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC) actualTime:nil error:nil];
        UIImage *videoImage = [[UIImage alloc] initWithCGImage:cgimage];
        kGCD_player_main(^{
            if (placeholder) placeholder(videoImage);
        });
        [KJScreenshotsManager kj_saveVideoCoverImage:videoImage videoURL:videoURL];
        CGImageRelease(cgimage);
    });
}

#pragma mark - 封面图

#define kPlayerCacheImage \
[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject \
stringByAppendingPathComponent:@"videoImages"]

/// 缓存封面图名
NS_INLINE NSString * kVideoCoverImageNameMD5(NSString * key){
    const char *value = [key UTF8String];
    unsigned char buffer[CC_MD5_DIGEST_LENGTH];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    CC_MD5(value, (CC_LONG)strlen(value), buffer);
#pragma clang diagnostic pop
    NSMutableString * outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [outputString appendFormat:@"%02x",buffer[count]];
    }
    return outputString.mutableCopy;
}

/// 存入视频封面图
+ (void)kj_saveVideoCoverImage:(UIImage *)image videoURL:(NSURL *)videoURL{
    NSData *data = UIImageJPEGRepresentation(image, 1.0);
    NSString *name = kVideoCoverImageNameMD5(videoURL.resourceSpecifier?:videoURL.absoluteString);
    NSString *directoryPath = kPlayerCacheImage;
    if (![[NSFileManager defaultManager] fileExistsAtPath:directoryPath isDirectory:nil]) {
        NSError *error = nil;
        BOOL isOK = [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath
                                              withIntermediateDirectories:YES
                                                               attributes:nil
                                                                    error:&error];
        if (isOK && error == nil) { } else return;
    }
    @autoreleasepool {
        NSString *path = [directoryPath stringByAppendingPathComponent:name];
        [[NSFileManager defaultManager] createFileAtPath:path contents:data attributes:nil];
    }
}
/// 读取视频封面图
+ (UIImage *)kj_getVideoCoverImageWithURL:(NSURL *)url{
    NSString *name = kVideoCoverImageNameMD5(url.resourceSpecifier?:url.absoluteString);
    NSData *data = [NSData dataWithContentsOfFile:[kPlayerCacheImage stringByAppendingPathComponent:name]];
    return [UIImage imageWithData:data];
}
/// 清除视频封面图
+ (void)kj_clearVideoCoverImageWithURL:(NSURL *)url{
    NSString *name = kVideoCoverImageNameMD5(url.resourceSpecifier?:url.absoluteString);
    NSString *directoryPath = [kPlayerCacheImage stringByAppendingPathComponent:name];
    if ([[NSFileManager defaultManager] fileExistsAtPath:directoryPath isDirectory:nil]) {
        [[NSFileManager defaultManager] removeItemAtPath:directoryPath error:nil];
    }
}
/// 清除全部封面缓存
+ (void)kj_clearAllVideoCoverImage{
    NSString *directoryPath = kPlayerCacheImage;
    if ([[NSFileManager defaultManager] fileExistsAtPath:directoryPath isDirectory:nil]) {
        [[NSFileManager defaultManager] removeItemAtPath:directoryPath error:nil];
    }
}

@end
