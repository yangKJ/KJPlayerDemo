//
//  KJPlayerView.h
//  KJPlayer
//
//  Created by yangkejun on 2021/8/12.
//  https://github.com/yangKJ/KJPlayerDemo
//  播放器视图基类，播放器控件父类

#import <UIKit/UIKit.h>
#import "KJPlayerProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@protocol KJPlayerBaseViewDelegate;
@interface KJPlayerView : UIImageView
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
/// 是否开启自动旋转，默认yes
@property (nonatomic,assign) BOOL autoRotate;
/// 是否为全屏，名字别乱改后面kvc有使用
@property (nonatomic,assign) BOOL isFullScreen;
/// 操作面板自动隐藏时间，默认2秒然后为零表示不隐藏
@property (nonatomic,assign) NSTimeInterval autoHideTime;
/// 当前屏幕状态，名字别乱改后面kvc有使用
@property (nonatomic,assign,readonly) KJPlayerVideoScreenState screenState;
/// 当前操作面板状态，名字别乱改后面kvc有使用
@property (nonatomic,assign,readonly) BOOL displayOperation;

#pragma mark - method

/// 隐藏操作面板
- (void)kj_hiddenOperationView NS_REQUIRES_SUPER;
/// 显示操作面板
- (void)kj_displayOperationView NS_REQUIRES_SUPER;
/// 取消收起操作面板，可用于滑动滑杆时刻不自动隐藏
- (void)kj_cancelHiddenOperationView NS_REQUIRES_SUPER;

@end

NS_ASSUME_NONNULL_END
