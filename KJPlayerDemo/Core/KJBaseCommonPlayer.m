//
//  KJBaseCommonPlayer.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/10.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJBaseCommonPlayer.h"

@interface KJBaseCommonPlayer ()
@property (nonatomic,strong) UITableView *bindTableView;
@property (nonatomic,strong) NSIndexPath *indexPath;
@property (nonatomic,strong) CAShapeLayer *loadingLayer;
@property (nonatomic,strong) CATextLayer *hintTextLayer;
@property (nonatomic,strong) CALayer *backLayer;
@property (nonatomic,assign) CGFloat hintMaxWidth;
@property (nonatomic,strong) UIColor *hintBackgroundColor;
@property (nonatomic,strong) UIColor *hintTextColor;
@property (nonatomic,strong) UIFont *hintFont;
@end

@implementation KJBaseCommonPlayer
PLAYER_COMMON_PROPERTY PLAYER_COMMON_UI_PROPERTY
@synthesize kVideoCanCacheURL;
static KJBaseCommonPlayer *_instance = nil;
static dispatch_once_t onceToken;
+ (instancetype)kj_sharedInstance{
    dispatch_once(&onceToken, ^{
        if (_instance == nil) {
            _instance = [[self alloc] init];
        }
    });
    return _instance;
}
+ (void)kj_attempDealloc{
    onceToken = 0;
    _instance = nil;
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self kj_saveRecordLastTime];
}
- (instancetype)init{
    self = [super init];
    if (self) {
        NSNotificationCenter * defaultCenter = [NSNotificationCenter defaultCenter];
        [defaultCenter addObserver:self selector:@selector(kj_playerAppDidEnterBackground:)
                              name:UIApplicationWillResignActiveNotification object:nil];
        [defaultCenter addObserver:self selector:@selector(kj_playerAppWillEnterForeground:)
                              name:UIApplicationDidBecomeActiveNotification object:nil];
        [defaultCenter addObserver:self selector:@selector(kj_playerOrientationChange:)
                              name:UIDeviceOrientationDidChangeNotification object:nil];
        [defaultCenter addObserver:self selector:@selector(kj_playerBaseViewChange:)
                              name:kPlayerBaseViewChangeNotification object:nil];
        
        //kvo
        NSKeyValueObservingOptions options = NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew;
        [self addObserver:self forKeyPath:@"state" options:options context:nil];
        [self addObserver:self forKeyPath:@"progress" options:options context:nil];
        [self addObserver:self forKeyPath:@"playError" options:options context:nil];
        [self addObserver:self forKeyPath:@"currentTime" options:options context:nil];
        
        //提示框默认值
        self.hintMaxWidth = 250;
        self.hintBackgroundColor = [UIColor.blackColor colorWithAlphaComponent:.6];
        self.hintTextColor = UIColor.whiteColor;
        self.hintFont = [UIFont systemFontOfSize:16];
    }
    return self;
}
#pragma mark - kvo
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"state"]) {
        if ([self.delegate respondsToSelector:@selector(kj_player:state:)]) {
            if ([change[@"new"] intValue] != [change[@"old"] intValue]) {
                kGCD_player_main(^{
                    KJPlayerState state = (KJPlayerState)[change[@"new"] intValue];
                    [self.delegate kj_player:self state:state];
                });
            }
        }
    }else if ([keyPath isEqualToString:@"progress"]) {
        if ([self.delegate respondsToSelector:@selector(kj_player:loadProgress:)]) {
            CGFloat new = [change[@"new"] floatValue];
            CGFloat old = [change[@"old"] floatValue];
            if (new != old || (new == 0 && old == 0)) {
                kGCD_player_main(^{
                    [self.delegate kj_player:self loadProgress:new];
                });
            }
        }
    }else if ([keyPath isEqualToString:@"playError"]) {
        if ([self.delegate respondsToSelector:@selector(kj_player:playFailed:)]) {
            if (change[@"new"] != change[@"old"]) {
                kGCD_player_main(^{
                    [self.delegate kj_player:self playFailed:change[@"new"]];
                });
            }
        }
    }else if ([keyPath isEqualToString:@"currentTime"]) {
        if ([self.delegate respondsToSelector:@selector(kj_player:currentTime:)]) {
            CGFloat new = [change[@"new"] floatValue];
            CGFloat old = [change[@"old"] floatValue];
            if (new != old || (new == 0 && old == 0)) {
                kGCD_player_main(^{
                    [self.delegate kj_player:self currentTime:new];
                });
            }
        }
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - NSNotification
//进入后台
- (void)kj_playerAppDidEnterBackground:(NSNotification*)notification{
    if (self.backgroundPause) {
        [self kj_pause];
    }else{
//        AVAudioSession * session = [AVAudioSession sharedInstance];
//        [session setCategory:AVAudioSessionCategoryPlayback error:nil];
//        [session setActive:YES error:nil];
    }
}
//进入前台
- (void)kj_playerAppWillEnterForeground:(NSNotification*)notification{
    if (self.roregroundResume && self.userPause == NO && ![self isPlaying]) {
        [self kj_resume];
    }
}
//屏幕旋转
- (void)kj_playerOrientationChange:(NSNotification*)notification{
    
}
//KJBasePlayerView位置和尺寸发生变化
- (void)kj_playerBaseViewChange:(NSNotification*)notification{
    CGFloat width = self.loadingLayer.frame.size.width;
    self.loadingLayer.frame = CGRectMake((self.playerView.frame.size.width-width)/2.f, (self.playerView.frame.size.height-width)/2.f, width, width);
}
#pragma mark - child method（子类实现处理）
/* 准备播放 */
- (void)kj_play{ }
/* 重播 */
- (void)kj_replay{ }
/* 继续 */
- (void)kj_resume{ }
/* 暂停 */
- (void)kj_pause{ }
/* 停止 */
- (void)kj_stop{ }

#pragma mark - public method
+ (UIWindow*)kj_window{
    return ({
        UIWindow *window;
        if (@available(iOS 13.0, *)) {
            window = [UIApplication sharedApplication].windows.firstObject;
        }else{
            window = [UIApplication sharedApplication].keyWindow;
        }
        window;
    });
}
- (void)kj_saveRecordLastTime{
    @synchronized (@(self.recordLastTime)) {
        if (self.recordLastTime) {
            kRecordLastTime(self.currentTime, kPlayerIntactName(self.originalURL));
        }
    }
}

#pragma mark - table
/* 列表上播放绑定tableView */
- (void)kj_bindTableView:(UITableView*)tableView indexPath:(NSIndexPath*)indexPath{
    self.bindTableView = tableView;
    self.indexPath = indexPath;
}

#pragma mark - getter
@dynamic kVideoPlaceholderImage;
- (void (^)(void(^)(UIImage *image),NSURL *,NSTimeInterval))kVideoPlaceholderImage{
    return ^(void(^xxblock)(UIImage*),NSURL *videoURL,NSTimeInterval time){
        kGCD_player_async(^{
            UIImage *image = [KJCachePlayerManager kj_getVideoCoverImageWithURL:videoURL];
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
            [KJCachePlayerManager kj_saveVideoCoverImage:videoImage VideoURL:videoURL];
            CGImageRelease(cgimage);
        });
    };
}

#pragma mark - Animation
- (CAShapeLayer *)loadingLayer{
    if (!_loadingLayer) {
        CGFloat width = 40;
        _loadingLayer = [self kj_setAnimationSize:CGSizeMake(width, width) color:UIColor.whiteColor];
        _loadingLayer.frame = CGRectMake((self.playerView.frame.size.width-width)/2.f, (self.playerView.frame.size.height-width)/2.f, width, width);
    }
    return _loadingLayer;
}
/* 圆圈加载动画 */
- (void)kj_startAnimation{
    if (CGRectEqualToRect(CGRectZero, self.playerView.frame)) {
        return;
    }
    if (self.loadingLayer.superlayer == nil) {
        [self.playerView.layer addSublayer:self.loadingLayer];
    }
    if (self.loadingLayer.isHidden) {
        self.loadingLayer.hidden = NO;
    }
}
/* 停止动画 */
- (void)kj_stopAnimation{
    [UIView animateWithDuration:1.f animations:^{
        self.loadingLayer.hidden = YES;
    }];
}
/* 圆圈加载动画 */
- (CAShapeLayer*)kj_setAnimationSize:(CGSize)size color:(UIColor*)color{
    CGFloat beginTime = 0.5;
    CGFloat strokeStartDuration = 1.2;
    CGFloat strokeEndDuration = 0.7;
    CGFloat width = size.width;
    CGFloat height = size.height;
    CGFloat lineWidth = 2.f;
    
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotationAnimation.byValue = @(M_PI * 2);
    rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
    CABasicAnimation *strokeEndAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    strokeEndAnimation.duration = strokeEndDuration;
    strokeEndAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.4:0.0:0.2:1.0];
    strokeEndAnimation.fromValue = @(0);
    strokeEndAnimation.toValue = @(1);
    
    CABasicAnimation *strokeStartAnimation = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
    strokeStartAnimation.duration = strokeStartDuration;
    strokeStartAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.4:0.0:0.2:1.0];
    strokeStartAnimation.fromValue = @(0);
    strokeStartAnimation.toValue = @(1);
    strokeStartAnimation.beginTime = beginTime;
    
    CAAnimationGroup *groupAnimation = [CAAnimationGroup animation];
    groupAnimation.animations = @[rotationAnimation, strokeEndAnimation, strokeStartAnimation];
    groupAnimation.duration = strokeStartDuration + beginTime;
    groupAnimation.repeatCount = INFINITY;
    groupAnimation.removedOnCompletion = NO;
    groupAnimation.fillMode = kCAFillModeForwards;
    CAShapeLayer *circle = [CAShapeLayer layer];
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path addArcWithCenter:CGPointMake(width/2.f,height/2.f) radius:width/2.f startAngle:-M_PI/2.f endAngle:M_PI + M_PI/2.f clockwise:YES];
    circle.fillColor = nil;
    circle.strokeColor = color.CGColor;
    circle.lineWidth = lineWidth;
    circle.backgroundColor = nil;
    circle.path = path.CGPath;
    circle.frame = CGRectMake(0, 0, width, height);
    [circle addAnimation:groupAnimation forKey:@"animation"];
    
    return circle;
}

#pragma mark - hintText
- (void (^)(CGFloat, UIColor *, UIColor *, UIFont *))kVideoHintTextProperty{
    return ^(CGFloat maxWidth, UIColor *background, UIColor *textColor, UIFont *font){
        self.hintMaxWidth = maxWidth;
        self.hintBackgroundColor = background;
        self.hintTextColor = textColor;
        self.hintFont = font;
    };
}
- (CALayer *)backLayer{
    if (!_backLayer) {
        _backLayer = [CALayer layer];
        [_backLayer addSublayer:self.hintTextLayer];
        _backLayer.backgroundColor = self.hintBackgroundColor.CGColor;
        _backLayer.cornerRadius = 7;
    }
    return _backLayer;
}
- (CATextLayer *)hintTextLayer{
    if (!_hintTextLayer) {
        CATextLayer * textLayer = [CATextLayer layer];
        textLayer.font = (__bridge CFTypeRef _Nullable)(self.hintFont.fontName);
        textLayer.fontSize = self.hintFont.pointSize;
        textLayer.foregroundColor = self.hintTextColor.CGColor;
        textLayer.alignmentMode = kCAAlignmentCenter;
        textLayer.contentsScale = [UIScreen mainScreen].scale;
        textLayer.wrapped = YES;
        _hintTextLayer = textLayer;
    }
    return _hintTextLayer;
}
/* 提示文字 */
- (void)kj_displayHintText:(id)text{
    [self kj_displayHintText:text max:self.hintMaxWidth];
}
- (void)kj_displayHintText:(id)text max:(float)max{
    [self kj_displayHintText:text time:1.f max:max position:KJPlayerHintPositionCenter];
}
- (void)kj_displayHintText:(id)text position:(id)position{
    [self kj_displayHintText:text time:1.f position:position];
}
- (void)kj_displayHintText:(id)text time:(NSTimeInterval)time{
    [self kj_displayHintText:text time:time position:KJPlayerHintPositionCenter];
}
- (void)kj_displayHintText:(id)text time:(NSTimeInterval)time position:(id)position{
    [self kj_displayHintText:text time:time max:self.hintMaxWidth position:position];
}
- (void)kj_displayHintText:(id)text time:(NSTimeInterval)time max:(float)max position:(id)position{
    kGCD_player_main(^{
        if (CGRectEqualToRect(CGRectZero, self.playerView.frame)) {
            return;
        }        
    });
    NSString *tempText;
    if ([text isKindOfClass:[NSAttributedString class]]){
        tempText = [text string];
        if (tempText.length == 0) return;
        self.hintTextLayer.string = text;
    }else if ([text isKindOfClass:[NSString class]]){
        if (((NSString*)text).length == 0) return;
        tempText = text;
        CGFloat lineHeight = self.hintTextLayer.fontSize;
        NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
        paragraphStyle.maximumLineHeight = lineHeight;
        paragraphStyle.minimumLineHeight = lineHeight;
        NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
        [attributes setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];
        [attributes setValue:self.hintFont forKey:NSFontAttributeName];
        [attributes setValue:self.hintTextColor forKey:NSForegroundColorAttributeName];
        self.hintTextLayer.string = [[NSAttributedString alloc] initWithString:text attributes:attributes];
    }else{
        return;
    }
    
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.lineBreakMode = NSLineBreakByCharWrapping;
    NSDictionary *dict = @{NSFontAttributeName:[UIFont fontWithName:self.hintTextLayer.font size:self.hintTextLayer.fontSize]};
    CGSize size = [tempText boundingRectWithSize:CGSizeMake(max, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil].size;
    CGPoint point = CGPointZero;
    CGFloat padding = 20;
    if ([position isKindOfClass:[NSString class]]) {
        CGFloat w = size.width + padding + padding;
        CGFloat h = size.height + padding;
        CGFloat w2 = self.playerView.frame.size.width;
        CGFloat h2 = self.playerView.frame.size.height;
        if ([position caseInsensitiveCompare:KJPlayerHintPositionCenter] == NSOrderedSame) {
            point = CGPointMake((w2-w)/2.f, (h2-h)/2.f);
        }else if ([position caseInsensitiveCompare:KJPlayerHintPositionBottom] == NSOrderedSame) {
            point = CGPointMake((w2-w)/2.f, h2-padding-h);
        }else if ([position caseInsensitiveCompare:KJPlayerHintPositionTop] == NSOrderedSame) {
            point = CGPointMake((w2-w)/2.f, padding);
        }else if ([position caseInsensitiveCompare:KJPlayerHintPositionLeftBottom] == NSOrderedSame) {
            point = CGPointMake(padding, h2-padding-h);
        }else if ([position caseInsensitiveCompare:KJPlayerHintPositionRightBottom] == NSOrderedSame) {
            point = CGPointMake(w2-w-padding, h2-padding-h);
        }else if ([position caseInsensitiveCompare:KJPlayerHintPositionLeftTop] == NSOrderedSame) {
            point = CGPointMake(padding, padding);
        }else if ([position caseInsensitiveCompare:KJPlayerHintPositionRightTop] == NSOrderedSame) {
            point = CGPointMake(w2-w-padding, padding);
        }else if ([position caseInsensitiveCompare:KJPlayerHintPositionLeftCenter] == NSOrderedSame) {
            point = CGPointMake(padding, (h2-h)/2.f);
        }else if ([position caseInsensitiveCompare:KJPlayerHintPositionRightCenter] == NSOrderedSame) {
            point = CGPointMake(w2-w-padding, (h2-h)/2.f);
        }
    }else if ([position isKindOfClass:[NSValue class]]) {
        point = [position CGPointValue];
    }
    
    self.hintTextLayer.frame = CGRectMake(padding*.5, padding*.5, size.width+padding, 1.5*size.height);
    self.backLayer.frame = CGRectMake(point.x, point.y, size.width+padding+padding, size.height+padding+3);
    if (self.backLayer.superlayer == nil) {
        [self.playerView.layer addSublayer:self.backLayer];
    }
    self.backLayer.hidden = NO;
    /// 先取消上次的延时执行
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(kj_hideHintText) object:nil];
    if (time) {
        [self performSelector:@selector(kj_hideHintText) withObject:nil afterDelay:time];
    }
}
/* 隐藏提示文字 */
- (void)kj_hideHintText{
    self.backLayer.hidden = YES;
}

@end
