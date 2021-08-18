//
//  KJBasePlayer+KJScreenshots.m
//  KJPlayer
//
//  Created by 77。 on 2021/8/19.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJBasePlayer+KJScreenshots.h"

@implementation KJBasePlayer (KJScreenshots)


- (void (^)(void (^)(UIImage *)))kVideoTimeScreenshots{
    return ^(void (^xxblock)(UIImage *)){
        kGCD_player_async(^{
            KJPlayerAssetType type = kPlayerVideoAesstType(self.originalURL);
            if (type == KJPlayerAssetTypeNONE) {
                kGCD_player_main(^{
                    if (xxblock) xxblock(nil);
                });
            } else if (type == KJPlayerAssetTypeHLS) {
                CVPixelBufferRef pixelBuffer = [self.playerOutput copyPixelBufferForItemTime:self.player.currentTime itemTimeForDisplay:nil];
                CIImage *ciImage = [CIImage imageWithCVPixelBuffer:pixelBuffer];
                CIContext *temporaryContext = [CIContext contextWithOptions:nil];
                CGImageRef imageRef = [temporaryContext createCGImage:ciImage fromRect:CGRectMake(0, 0, CVPixelBufferGetWidth(pixelBuffer), CVPixelBufferGetHeight(pixelBuffer))];
                UIImage *newImage = [UIImage imageWithCGImage:imageRef];
                kGCD_player_main(^{
                    if (xxblock) xxblock(newImage);
                });
                CGImageRelease(imageRef);
                CVBufferRelease(pixelBuffer);
            } else {
                CGImageRef imageRef = [self.imageGenerator copyCGImageAtTime:self.player.currentTime actualTime:NULL error:NULL];
                UIImage *newImage = [[UIImage alloc] initWithCGImage:imageRef];
                kGCD_player_main(^{
                    if (xxblock) xxblock(newImage);
                });
                CGImageRelease(imageRef);
            }
        });
    };
}
- (void (^)(void(^)(UIImage *image),NSURL *,NSTimeInterval))kVideoPlaceholderImage{
    return ^(void(^xxblock)(UIImage*),NSURL *videoURL,NSTimeInterval time){
        kGCD_player_async(^{
            UIImage *image = [KJCacheManager kj_getVideoCoverImageWithURL:videoURL];
            if (image) {
                kGCD_player_main(^{
                    if (xxblock) xxblock(image);
                });
                return;
            }
            AVURLAsset *asset = [AVURLAsset URLAssetWithURL:videoURL options:self.requestHeader];
            if ([asset tracksWithMediaType:AVMediaTypeVideo].count == 0) {
                kGCD_player_main(^{
                    if (xxblock) xxblock(nil);
                });
            }
            AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
            generator.appliesPreferredTrackTransform = YES;
            generator.requestedTimeToleranceAfter = kCMTimeZero;
            generator.requestedTimeToleranceBefore = kCMTimeZero;
            CGImageRef cgimage = [generator copyCGImageAtTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC) actualTime:nil error:nil];
            UIImage *videoImage = [[UIImage alloc] initWithCGImage:cgimage];
            kGCD_player_main(^{
                if (xxblock) xxblock(videoImage);
            });
            [KJCacheManager kj_saveVideoCoverImage:videoImage VideoURL:videoURL];
            CGImageRelease(cgimage);
        });
    };
}


@end
