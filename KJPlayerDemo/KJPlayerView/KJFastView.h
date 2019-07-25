//
//  KJFastView.h
//  KJPlayerDemo
//
//  Created by 杨科军 on 2019/7/22.
//  Copyright © 2019 杨科军. All rights reserved.
//  快进快退view

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KJFastView : UIView

@property(nonatomic,strong) UIProgressView *progressView;
@property(nonatomic,strong) UILabel *timeLabel;

//记录触摸开始时的视频播放的时间
@property (nonatomic,assign) CGFloat touchBeginValue;
//正在手势滑动快进快退
@property (nonatomic,assign) BOOL moveGestureFast;

/// 设置数据
- (void)kj_updateFastValue:(CGFloat)value TotalTime:(CGFloat)time;

@end

NS_ASSUME_NONNULL_END
