//
//  KJLoadingPlayerVC.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/16.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJLoadingPlayerVC.h"

@interface KJLoadingPlayerVC ()<KJPlayerBaseViewDelegate>{
    int index;
}
@property(nonatomic,strong)KJPlayer *player;
@property(nonatomic,strong)KJBasePlayerView *basePlayerView;
@end

@implementation KJLoadingPlayerVC
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;
    
    KJBasePlayerView *backview = [[KJBasePlayerView alloc]initWithFrame:CGRectMake(0, PLAYER_STATUSBAR_NAVIGATION_HEIGHT, self.view.frame.size.width, self.view.frame.size.width*9/16.)];
    self.basePlayerView = backview;
    [self.view addSubview:backview];
    backview.gestureType = KJPlayerGestureTypeAll;
    self.basePlayerView.delegate = self;
    self.basePlayerView.kVideoHintTextInfo(^(KJPlayerHintInfo * _Nonnull info) {
        info.maxWidth = 110;
        info.background = [UIColor.greenColor colorWithAlphaComponent:0.3];
        info.textColor = UIColor.greenColor;
        info.font = [UIFont systemFontOfSize:15];
    });
    PLAYER_WEAKSELF;
    self.basePlayerView.kVideoChangeScreenState = ^(KJPlayerVideoScreenState state) {
        if (state == KJPlayerVideoScreenStateFullScreen) {
            [weakself.navigationController setNavigationBarHidden:YES animated:YES];
        }else{
            [weakself.navigationController setNavigationBarHidden:NO animated:YES];
        }
    };
    
    KJPlayer *player = [[KJPlayer alloc]init];
    self.player = player;
    player.playerView = backview;
    [player kj_startAnimation];
    
    [self.player kj_displayHintText:@"顺便测试文本提示框长文字" time:0 position:KJPlayerHintPositionBottom];
    {
        UIButton *button = [UIButton buttonWithType:(UIButtonTypeCustom)];
        button.frame = CGRectMake(30, 350, 100, 50);
        button.backgroundColor = [UIColor.greenColor colorWithAlphaComponent:0.5];
        [button setTitleColor:UIColor.blueColor forState:(UIControlStateNormal)];
        [button setTitleColor:UIColor.blueColor forState:(UIControlStateSelected)];
        [button setTitle:@"取消加载" forState:(UIControlStateNormal)];
        [button setTitle:@"开始加载" forState:(UIControlStateSelected)];
        [self.view addSubview:button];
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:(UIControlEventTouchUpInside)];
    }{
        UIButton *button = [UIButton buttonWithType:(UIButtonTypeCustom)];
        button.frame = CGRectMake(self.view.frame.size.width-100-30, 350, 100, 50);
        button.backgroundColor = [UIColor.greenColor colorWithAlphaComponent:0.5];
        [button setTitleColor:UIColor.blueColor forState:(UIControlStateNormal)];
        [button setTitle:@"切换位置" forState:(UIControlStateNormal)];
        [self.view addSubview:button];
        [button addTarget:self action:@selector(buttonAction2:) forControlEvents:(UIControlEventTouchUpInside)];
    }
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 120)];
    label.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/4*3);
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor.greenColor colorWithAlphaComponent:0.5];
    UIColor *color = [self kj_gradientColor:UIColor.redColor,UIColor.orangeColor,UIColor.yellowColor,UIColor.greenColor,UIColor.cyanColor,UIColor.blueColor,UIColor.purpleColor,nil](CGSizeMake(label.frame.size.width, 1));
    label.textColor = color;
    label.font = [UIFont fontWithName:@"iconfont" size:100];
    label.text = @"\U0000e82b";
    [self.view addSubview:label];
}
- (UIColor*(^)(CGSize))kj_gradientColor:(UIColor*)color,...{
    NSMutableArray * colors = [NSMutableArray arrayWithObjects:(id)color.CGColor,nil];
    va_list args;UIColor * arg;
    va_start(args, color);
    while ((arg = va_arg(args, UIColor *))) {
        [colors addObject:(id)arg.CGColor];
    }
    va_end(args);
    return ^UIColor*(CGSize size){
        UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
        CGGradientRef gradient = CGGradientCreateWithColors(colorspace, (__bridge CFArrayRef)colors, NULL);
        CGContextDrawLinearGradient(context, gradient, CGPointZero, CGPointMake(size.width, size.height), 0);
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        CGGradientRelease(gradient);
        CGColorSpaceRelease(colorspace);
        UIGraphicsEndImageContext();
        return [UIColor colorWithPatternImage:image];
    };
}

- (void)buttonAction:(UIButton*)sender{
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self.player kj_stopAnimation];
    }else{
        [self.player kj_startAnimation];
    }
}
- (void)buttonAction2:(UIButton*)sender{
    NSArray *temps = @[KJPlayerHintPositionCenter,
                       KJPlayerHintPositionBottom,
                       KJPlayerHintPositionLeftBottom,
                       KJPlayerHintPositionRightBottom,
                       KJPlayerHintPositionLeftTop,
                       KJPlayerHintPositionRightTop,
                       KJPlayerHintPositionTop,
                       KJPlayerHintPositionLeftCenter,
                       KJPlayerHintPositionRightCenter
    ];
    index++;
    if (index>=temps.count) {
        index = 0;
    }
    [self.player kj_displayHintText:@"两秒后消失!!" time:2 position:temps[index]];
}

#pragma mark - KJPlayerBaseViewDelegate
/* 单双击手势反馈 */
- (void)kj_basePlayerView:(KJBasePlayerView*)view isSingleTap:(BOOL)tap{
    if (tap) {
        if (view.displayOperation) {
            [view kj_hiddenOperationView];
        }else{
            [view kj_displayOperationView];
        }
    }
}

@end
