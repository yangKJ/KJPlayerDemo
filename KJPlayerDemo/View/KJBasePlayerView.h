//
//  KJBasePlayerView.h
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/10.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo
//  播放器视图基类，播放器控件父类

#import <UIKit/UIKit.h>
#import "KJPlayerType.h"
#import "KJPlayerSystemLayer.h"
#import "KJPlayerFastLayer.h"
#import "KJPlayerLoadingLayer.h"
#import "KJPlayerHintTextLayer.h"
NS_ASSUME_NONNULL_BEGIN
/* 控件位置和大小发生改变信息通知 */
extern NSString *kPlayerBaseViewChangeNotification;
/* 控件位置和大小发生改变key */
extern NSString *kPlayerBaseViewChangeKey;
@protocol KJPlayerBaseViewDelegate;
@interface KJBasePlayerView : UIImageView
/* 委托代理 */
@property (nonatomic,weak) id <KJPlayerBaseViewDelegate> delegate;
/* 主色调，默认白色 */
@property (nonatomic,strong) UIColor *mainColor;
/* 副色调，默认红色 */
@property (nonatomic,strong) UIColor *viceColor;
/* 支持手势，支持多枚举 */
@property (nonatomic,assign) KJPlayerGestureType gestureType;
/* 长按执行时间，默认1秒 */
@property (nonatomic,assign) NSTimeInterval longPressTime;
/* 操作面板自动隐藏时间，为0表示不隐藏 */
@property (nonatomic,assign) NSTimeInterval autoHideTime;
/* 小屏状态下是否显示返回按钮，默认不显示 */
@property (nonatomic,assign) BOOL smallScreenHiddenBackButton;
/* 全屏状态下是否显示返回按钮，默认显示 */
@property (nonatomic,assign) BOOL fullScreenHiddenBackButton;
/* 是否为全屏 */
@property (nonatomic,assign) BOOL isFullScreen;
/* 当前屏幕状态 */
@property (nonatomic,assign,readonly) KJPlayerVideoScreenState screenState;
/* 当前屏幕状态发生改变 */
@property (nonatomic,copy,readwrite) void (^kVideoChangeScreenState)(KJPlayerVideoScreenState state);
/* 返回回调 */
@property (nonatomic,copy,readwrite) void (^kVideoClickButtonBack)(KJBasePlayerView *view);
/* 提示文字面板属性，默认最大宽度250px */
@property (nonatomic,copy,readonly) void (^kVideoHintTextInfo)(void(^)(KJPlayerHintInfo *info));

#pragma mark - 控件
/* 快进快退进度控件 */
@property (nonatomic,strong) KJPlayerFastLayer *fastLayer;
/* 音量亮度控件 */
@property (nonatomic,strong) KJPlayerSystemLayer *vbLayer;
/* 加载动画层 */
@property (nonatomic,strong) KJPlayerLoadingLayer *loadingLayer;
/* 文本提示框 */
@property (nonatomic,strong) KJPlayerHintTextLayer *hintTextLayer;

#pragma mark - method
/* 隐藏操作面板，是否隐藏返回按钮 */
- (void)kj_hiddenHandleControlAndBackButton:(BOOL)hide;
/* 显示操作面板 */
- (void)kj_displayHandleControl;

@end
/// 委托代理
@protocol KJPlayerBaseViewDelegate <NSObject>
@optional;
/* 单双击手势反馈 */
- (void)kj_basePlayerView:(KJBasePlayerView*)view isSingleTap:(BOOL)tap;
/* 长按手势反馈 */
- (void)kj_basePlayerView:(KJBasePlayerView*)view longPress:(UILongPressGestureRecognizer*)longPress;
/* 进度手势反馈，不替换UI请返回当前时间和总时间，范围-1 ～ 1 */
- (NSArray*)kj_basePlayerView:(KJBasePlayerView*)view progress:(float)progress end:(BOOL)end;
/* 音量手势反馈，是否替换自带UI，范围0 ～ 1 */
- (BOOL)kj_basePlayerView:(KJBasePlayerView*)view volumeValue:(float)value;
/* 亮度手势反馈，是否替换自带UI，范围0 ～ 1 */
- (BOOL)kj_basePlayerView:(KJBasePlayerView*)view brightnessValue:(float)value;

@end


NS_ASSUME_NONNULL_END
