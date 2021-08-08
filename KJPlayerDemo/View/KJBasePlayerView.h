//
//  KJBasePlayerView.h
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/10.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo
//  播放器视图基类，播放器控件父类

#import <UIKit/UIKit.h>
#import "KJPlayerProtocol.h"
#import "KJPlayerSystemLayer.h"
#import "KJPlayerFastLayer.h"
#import "KJPlayerLoadingLayer.h"
#import "KJPlayerHintLayer.h"
#import "KJPlayerOperationView.h"
#import "KJPlayerButton.h"

NS_ASSUME_NONNULL_BEGIN
/// 控件位置和大小发生改变信息通知
static NSString * kPlayerBaseViewChangeNotification = @"kPlayerBaseViewNotification";
/// 控件位置和大小发生改变key
static NSString * kPlayerBaseViewChangeKey = @"kPlayerBaseViewKey";

@protocol KJPlayerBaseViewDelegate;
@interface KJBasePlayerView : UIImageView
/// 委托代理
@property (nonatomic,weak) id <KJPlayerBaseViewDelegate> delegate;
/// 主色调，默认白色
@property (nonatomic,strong) UIColor *mainColor;
/// 副色调，默认红色
@property (nonatomic,strong) UIColor *viceColor;
/// 支持手势，支持多枚举
@property (nonatomic,assign) KJPlayerGestureType gestureType;
/// 长按执行时间，默认1秒
@property (nonatomic,assign) NSTimeInterval longPressTime;
/// 操作面板自动隐藏时间，默认2秒然后为零表示不隐藏
@property (nonatomic,assign) NSTimeInterval autoHideTime;
/// 操作面板高度，默认60px
@property (nonatomic,assign) CGFloat operationViewHeight;
/// 当前操作面板状态
@property (nonatomic,assign,readonly) BOOL displayOperation;
/// 隐藏操作面板时是否隐藏返回按钮，默认yes
@property (nonatomic,assign) BOOL isHiddenBackButton;
/// 小屏状态下是否显示返回按钮，默认yes
@property (nonatomic,assign) BOOL smallScreenHiddenBackButton;
/// 全屏状态下是否显示返回按钮，默认no
@property (nonatomic,assign) BOOL fullScreenHiddenBackButton;
/// 是否开启自动旋转，默认yes
@property (nonatomic,assign) BOOL autoRotate;
/// 是否为全屏，名字别乱改后面kvc有使用
@property (nonatomic,assign) BOOL isFullScreen;
/// 当前屏幕状态，名字别乱改后面kvc有使用
@property (nonatomic,assign,readonly) KJPlayerVideoScreenState screenState;

#pragma mark - subview

/// 快进快退进度控件
@property (nonatomic,strong) KJPlayerFastLayer *fastLayer;
/// 音量亮度控件
@property (nonatomic,strong) KJPlayerSystemLayer *vbLayer;
/// 加载动画层
@property (nonatomic,strong) KJPlayerLoadingLayer *loadingLayer;
/// 文本提示框
@property (nonatomic,strong) KJPlayerHintLayer *hintTextLayer;
/// 顶部操作面板
@property (nonatomic,strong) KJPlayerOperationView *topView;
/// 底部操作面板
@property (nonatomic,strong) KJPlayerOperationView *bottomView;
/// 返回按钮
@property (nonatomic,strong) KJPlayerButton *backButton;
/// 锁屏按钮
@property (nonatomic,strong) KJPlayerButton *lockButton;
/// 播放按钮
@property (nonatomic,strong) KJPlayerButton *centerPlayButton;

#pragma mark - method

/// 隐藏操作面板，是否隐藏返回按钮
- (void)kj_hiddenOperationView;
/// 显示操作面板
- (void)kj_displayOperationView;
/// 取消收起操作面板，可用于滑动滑杆时刻不自动隐藏
- (void)kj_cancelHiddenOperationView;


#pragma mark - discard method

/// 当前屏幕状态发生改变
@property (nonatomic,copy,readwrite) void (^kVideoChangeScreenState)(KJPlayerVideoScreenState state) DEPRECATED_MSG_ATTRIBUTE("please use delegate [kj_basePlayerView:screenState:]");
/// 返回回调
@property (nonatomic,copy,readwrite) void (^kVideoClickButtonBack)(KJBasePlayerView * view) DEPRECATED_MSG_ATTRIBUTE("please use delegate [kj_basePlayerView:clickBack:]");

@end

NS_ASSUME_NONNULL_END
