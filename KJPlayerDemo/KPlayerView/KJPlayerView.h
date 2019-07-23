//
//  KJPlayerView.h
//  KJPlayerDemo
//
//  Created by 杨科军 on 2019/7/22.
//  Copyright © 2019 杨科军. All rights reserved.
//  播放器展示层

#import <UIKit/UIKit.h>
#import <MediaPlayer/MPVolumeView.h> /// 控制系统音量
#import "KJPlayer.h"
#import "KJFastView.h"
#import "KJLightView.h"

NS_ASSUME_NONNULL_BEGIN

//手势操作的类型
typedef NS_ENUM(NSUInteger,KJPlayerGestureType) {
    KJPlayerGestureTypeProgress = 0, //视频进度调节操作
    KJPlayerGestureTypeVoice    = 1, //声音调节操作
    KJPlayerGestureTypeLight    = 2, //屏幕亮度调节操作
    KJPlayerGestureTypeNone     = 3, //无任何操作
};

@interface KJPlayerView : UIView

/* 播放视频并设置开始播放时间 */
- (void)kj_setPlayWithURL:(id)url StartTime:(CGFloat)time;
/** 是否用视频第一帧显示为占位背景，默认yes */
@property (nonatomic,assign) BOOL haveFristImage;
/** 是否使用手势控制音量，默认yes */
@property (nonatomic,assign) BOOL enableVolumeGesture;
/** 判断当前的状态是否显示为全屏 */
@property (nonatomic,assign) BOOL fullScreen;
/** 设置自动隐藏面板时间，默认5秒 */
@property (nonatomic,assign) CGFloat autoHideTime;


/** 显示播放器 */
@property (nonatomic,strong) UIView *contentView;
/** 视频的显示模式,默认按原视频比例显示，是竖屏的就显示出竖屏的，两边留黑 AVLayerVideoGravityResizeAspect */
@property (nonatomic,assign) AVLayerVideoGravity videoGravity;
/** 底部操作工具栏 */
@property (nonatomic,strong) UIImageView *bottomView;
/** 顶部操作工具栏 */
@property (nonatomic,strong) UIImageView *topView;
/** 开始播放前背景占位图片 */
@property (nonatomic,strong) UIImageView *backImageView;
/** 显示播放视频的title */
@property (nonatomic,strong) UILabel *topTitleLabel;
/** 控制全屏的按钮 */
@property (nonatomic,strong) UIButton *fullScreenButton;
/** 播放暂停按钮 */
@property (nonatomic,strong) UIButton *playOrPauseButton;
/** 左上角关闭按钮 */
@property (nonatomic,strong) UIButton *backButton;
/** 给显示亮度的view添加毛玻璃效果 */
@property (nonatomic,strong) UIVisualEffectView *effectView;
/** 菊花（加载框）*/
@property (nonatomic,strong) UIActivityIndicatorView *loadingView;
//这个用来显示滑动屏幕时的时间
@property (nonatomic,strong) KJFastView *fastView;
/** 显示播放时间的UILabel */
@property (nonatomic,strong) UILabel *leftTimeLabel;
@property (nonatomic,strong) UILabel *rightTimeLabel;
/** 进度滑块 */
@property (nonatomic,strong) UISlider *playScheduleSlider;
/** 声音滑块 */
@property (nonatomic,strong) UISlider *volumeSlider;
/** 显示缓冲进度 */
@property (nonatomic,strong) UIProgressView *loadingProgress;

@end

NS_ASSUME_NONNULL_END
