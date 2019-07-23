//
//  ViewController.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2019/7/20.
//  Copyright © 2019 杨科军. All rights reserved.
//

#import "ViewController.h"
#import "KJPlayerView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    KJPlayerView *view = [[KJPlayerView alloc] initWithFrame:CGRectMake(0, 20, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width*9/16)];
    view.backgroundColor = UIColor.cyanColor;
    [self.view addSubview:view];

    view.topTitleLabel.text = @"正在播放";
//    view.loadingProgress.frame = CGRectMake(20, 0, 200, 20);
//    NSURL *url = [NSURL URLWithString:@"https://mp4.vjshi.com/2018-03-30/1f36dd9819eeef0bc508414494d34ad9.mp4"];
    NSString *url = @"https://mp4.vjshi.com/2018-03-30/1f36dd9819eeef0bc508414494d34ad9.mp4";
    [view kj_setPlayWithURL:url StartTime:100];
}

@end
