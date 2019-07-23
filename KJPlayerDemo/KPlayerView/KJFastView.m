//
//  KJFastView.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2019/7/22.
//  Copyright © 2019 杨科军. All rights reserved.
//

#import "KJFastView.h"

@implementation KJFastView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self==[super initWithFrame:frame]) {
        [self kSetUI];
    }
    return self;
}

- (void)kSetUI{
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    self.stateImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 12, self.frame.size.width*.5, 30)];
    self.stateImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:self.stateImageView];
    CGFloat y = 12 + 30 + 12;
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, y, self.frame.size.width, 12)];
    self.timeLabel.textAlignment = NSTextAlignmentCenter;
    self.timeLabel.font = [UIFont systemFontOfSize:(12)];
    self.timeLabel.textColor = UIColor.whiteColor;
    [self addSubview:self.timeLabel];
}

@end
