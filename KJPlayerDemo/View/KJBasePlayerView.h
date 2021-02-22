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
NS_ASSUME_NONNULL_BEGIN
/* 控件位置和大小发生改变信息通知 */
extern NSString *kPlayerBaseViewChangeNotification;
/* 缓存相关信息接收key */
extern NSString *kPlayerBaseViewChangeKey;
@protocol KJPlayerBaseViewDelegate;
@interface KJBasePlayerView : UIImageView
/* 主色调，默认白色 */
@property (nonatomic,strong) UIColor *mainColor;
/* 窗口window */
@property (nonatomic,strong,class,readonly) UIWindow *window;
/* 委托代理 */
@property (nonatomic,weak) id <KJPlayerBaseViewDelegate> delegate;
/* 支持手势，支持多枚举 */
@property (nonatomic,assign) KJPlayerGestureType gestureType;
/* 长按执行时间，默认1秒 */
@property (nonatomic,assign) NSTimeInterval longPressTime;

#pragma mark - 控件
/* 快进快退进度控件 */
@property (nonatomic,strong) KJPlayerFastLayer *fastLayer;
/* 音量亮度控件 */
@property (nonatomic,strong) KJPlayerSystemLayer *vbLayer;

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
