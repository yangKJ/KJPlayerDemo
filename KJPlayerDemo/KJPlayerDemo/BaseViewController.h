//
//  BaseViewController.h
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/16.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import <UIKit/UIKit.h>
#import <KJPlayer/KJPlayerHeader.h>

NS_ASSUME_NONNULL_BEGIN

#ifdef DEBUG // 输出日志 (格式: [编译时间] [文件名] [方法名] [行号] [输出内容])
#define NSLog(FORMAT, ...) fprintf(stderr,"------- 🎈 给我点赞 🎈 -------\n编译时间:%s\n文件名:%s\n方法名:%s\n行号:%d\n打印信息:%s\n\n", __TIME__,[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],__func__,__LINE__,[[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String])
#else
#define NSLog(FORMAT, ...) nil
#endif

@interface BaseViewController : UIViewController

@property (nonatomic, strong) KJAVPlayer *player;
@property (nonatomic, strong) KJBasePlayerView *basePlayerView;
@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIProgressView *progressView;

/// 点击返回按钮
- (void)backItemClick;

@end

NS_ASSUME_NONNULL_END
