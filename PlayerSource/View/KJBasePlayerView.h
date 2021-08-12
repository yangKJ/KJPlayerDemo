//
//  KJBasePlayerView.h
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/10.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo
//  自定义控件UI

#import "KJPlayerView.h"
#import "KJPlayerSystemLayer.h"
#import "KJPlayerFastLayer.h"
#import "KJPlayerLoadingLayer.h"
#import "KJPlayerHintLayer.h"
#import "KJPlayerOperationView.h"
#import "KJPlayerButton.h"

NS_ASSUME_NONNULL_BEGIN

@interface KJBasePlayerView : KJPlayerView

/// 操作面板高度，默认60px
@property (nonatomic,assign) CGFloat operationViewHeight;
/// 隐藏操作面板时是否隐藏返回按钮，默认yes
@property (nonatomic,assign) BOOL isHiddenBackButton;
/// 小屏状态下是否显示返回按钮，默认yes
@property (nonatomic,assign) BOOL smallScreenHiddenBackButton;
/// 全屏状态下是否显示返回按钮，默认no
@property (nonatomic,assign) BOOL fullScreenHiddenBackButton;

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

@end

NS_ASSUME_NONNULL_END
