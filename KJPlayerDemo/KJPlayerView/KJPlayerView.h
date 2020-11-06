//
//  KJPlayerView.h
//  KJPlayerDemo
//
//  Created by 杨科军 on 2019/7/22.
//  Copyright © 2019 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo
//  播放器展示层

#import <UIKit/UIKit.h>
#import "KJPlayerViewModel.h"
#import "KJPlayer.h"
#import "KJFastView.h"
#import "KJLightView.h"
#import "KJDefinitionView.h"
#import "KJPlayerViewConfiguration.h"

NS_ASSUME_NONNULL_BEGIN
@class KJPlayerView;
@protocol KJPlayerViewDelegate <NSObject>
@optional;
/// 当前手机方向  同时也控制全屏和半屏切换  全屏:left和right  半屏:top和bottom
- (BOOL)kj_PlayerView:(KJPlayerView*)playerView DeviceDirection:(KJPlayerDeviceDirection)direction;
/// Top按钮事件 state:播放器状态  tag:200返回(左上角)、201功能按钮(右上角)
- (void)kj_PlayerView:(KJPlayerView*)playerView PlayerState:(KJPlayerState)state TopButton:(UIButton*)sender;
/// Bottom按钮事件  tag:520收藏、521下载、522清晰度
- (void)kj_PlayerView:(KJPlayerView*)playerView BottomButton:(UIButton*)sender;

@end

@interface KJPlayerView : UIView

/** 初始化 */
- (instancetype)initWithFrame:(CGRect)frame Configuration:(KJPlayerViewConfiguration*)configuration;
/** 委托 */
@property (nonatomic,weak) id<KJPlayerViewDelegate> delegate;
/// 配置信息
@property (nonatomic,strong,readonly) KJPlayerViewConfiguration *configuration;
/// 播放器
@property (nonatomic,strong,readonly) KJPlayer *player;

/** 视频地址数组，随机播放和顺序播放只有设置了该属性才生效 */
@property (nonatomic,strong) NSArray<KJPlayerViewModel*>*videoModelTemps;
/** 视频地址数组在数组中位置，随机播放和顺序播放只有设置了该属性才生效 */
@property (nonatomic,assign) NSInteger videoIndex;
/** 播放视频数据模型 */
@property (nonatomic,strong) KJPlayerViewModel *videoModel;
/** 跳转播放时间,默认为0 */
@property (nonatomic,assign) CGFloat seekTime;

/* ********************** 布局视图 ************************/
/** 播放器展示Layer */
@property (nonatomic,strong) AVPlayerLayer *playerLayer;
/** 显示播放器 */
@property (nonatomic,strong) UIView *contentView;
/** 底部操作工具栏 */
@property (nonatomic,strong) UIImageView *bottomView;
/** 顶部操作工具栏 */
@property (nonatomic,strong) UIImageView *topView;
/** 开始播放前背景占位图片 */
@property (nonatomic,strong) UIImageView *coverImageView;
/** 显示播放视频的title */
@property (nonatomic,strong) UILabel *topTitleLabel;
/** 控制全屏的按钮 */
@property (nonatomic,strong) UIButton *fullScreenButton;
/** 播放暂停按钮 */
@property (nonatomic,strong) UIButton *playOrPauseButton;
/** 左上角关闭按钮 */
@property (nonatomic,strong) UIButton *backButton;
/** 右上角功能按钮 */
@property (nonatomic,strong) UIButton *functionButton;
/** 显示播放时间的UILabel */
@property (nonatomic,strong) UILabel *leftTimeLabel;
@property (nonatomic,strong) UILabel *rightTimeLabel;
/** 进度滑块 */
@property (nonatomic,strong) UISlider *playScheduleSlider;
/** 显示缓冲进度 */
@property (nonatomic,strong) UIProgressView *loadingProgress;
/** 快进快退 */
@property (nonatomic,strong) KJFastView *fastView;
/** 声音滑块 */
@property (nonatomic,strong) UISlider *volumeSlider;
/** 亮度调节 */
@property (nonatomic,strong) KJLightView *lightView;
/** 菊花（加载框）*/
@property (nonatomic,strong) UIActivityIndicatorView *loadingView;

/** 收藏按钮 */
@property (nonatomic,strong) UIButton *collectButton;
/** 下载按钮 */
@property (nonatomic,strong) UIButton *downloadButton;
/** 清晰度按钮 */
@property (nonatomic,strong) UIButton *definitionButton;

@end

NS_ASSUME_NONNULL_END
