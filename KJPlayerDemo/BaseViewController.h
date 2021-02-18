//
//  BaseViewController.h
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/16.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BaseViewController : UIViewController
@property(nonatomic,strong)KJPlayer *player;
@property(nonatomic,strong)KJBasePlayerView *basePlayerView;
@property(nonatomic,strong)UISlider *slider;
@property(nonatomic,strong)UILabel *label;
@property(nonatomic,strong)UIProgressView *progressView;
- (void)backItemClick;
@end

NS_ASSUME_NONNULL_END
