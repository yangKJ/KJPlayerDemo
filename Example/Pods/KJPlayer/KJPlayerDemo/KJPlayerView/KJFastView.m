//
//  KJFastView.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2019/7/22.
//  Copyright © 2019 杨科军. All rights reserved.
//

#import "KJFastView.h"
#import "KJPlayerViewConfiguration.h"

@implementation KJFastView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self==[super initWithFrame:frame]) {
        [self kSetUI];
    }
    return self;
}

- (void)kSetUI{
    CGFloat H = self.frame.size.height / 4;
    CGFloat w = self.frame.size.width * 2 / 3;
    self.layer.cornerRadius = 5;
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, w, H)];
    self.timeLabel.center = CGPointMake(self.frame.size.width*.5, H*1.5);
    self.timeLabel.textAlignment = NSTextAlignmentCenter;
    self.timeLabel.font = [UIFont systemFontOfSize:(13)];
    self.timeLabel.textColor = UIColor.whiteColor;
    [self addSubview:self.timeLabel];
    
    self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    self.progressView.frame = CGRectMake(0, 0, w, 2);
    self.progressView.center = CGPointMake(self.frame.size.width*.5, H*3);
    [self addSubview:self.progressView];
}

- (void)setMoveGestureFast:(BOOL)moveGestureFast{
    _moveGestureFast = moveGestureFast;
    [UIView animateWithDuration:0.3 animations:^{
        self.hidden = !moveGestureFast;    
    }];
}

- (void)kj_updateFastValue:(CGFloat)value TotalTime:(CGFloat)time{
    CGFloat x = value / time;
    [self.progressView setProgress:x animated:YES];
    self.timeLabel.text = [NSString stringWithFormat:@"%@ / %@", [KJPlayerTool kj_playerConvertTime:value], [KJPlayerTool kj_playerConvertTime:time]];
}

@end
