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
/// 控件位置和大小发生改变信息通知
static NSString * kPlayerBaseViewChangeNotification = @"kPlayerBaseViewNotification";
/// 控件位置和大小发生改变key
static NSString * kPlayerBaseViewChangeKey = @"kPlayerBaseViewKey";

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
- (void)kj_hiddenOperationView;
/// 显示操作面板
- (void)kj_displayOperationView;
/// 取消收起操作面板，可用于滑动滑杆时刻不自动隐藏
- (void)kj_cancelHiddenOperationView;

#pragma mark - discard method

/// 当前屏幕状态发生改变
@property (nonatomic,copy,readwrite) void (^kVideoChangeScreenState)(KJPlayerVideoScreenState state) DEPRECATED_MSG_ATTRIBUTE("please use delegate [kj_basePlayerView:screenState:]");
/// 返回回调
@property (nonatomic,copy,readwrite) void (^kVideoClickButtonBack)(KJPlayerView * view) DEPRECATED_MSG_ATTRIBUTE("please use delegate [kj_basePlayerView:clickBack:]");

@end

@interface KJPlayerTime : NSObject

/// 当前播放时间
@property (nonatomic, assign) NSTimeInterval currentTime;
/// 视频总时长
@property (nonatomic, assign) NSTimeInterval totalTime;

@end

NS_ASSUME_NONNULL_END