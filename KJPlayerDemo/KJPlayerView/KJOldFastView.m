//
//  KJOldFastView.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2019/7/22.
//  Copyright © 2019 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJOldFastView.h"
#import "KJPlayerViewConfiguration.h"

@implementation KJOldFastView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.opaque = YES;
        self.layer.cornerRadius = 5;
        self.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.8];
        [self kj_setupViews];
    }
    return self;
}

- (void)kj_setupViews{
    CGFloat height = self.frame.size.height / 4;
    CGFloat width  = self.frame.size.width * 2 / 3;
    
    self.timeLabel.frame = CGRectMake((self.frame.size.width-width)/2, height, width, height);
    self.progressView.frame = CGRectMake((self.frame.size.width-width)/2, height*3-2, width, 2);
}
- (void)kj_updateFastValue:(CGFloat)value TotalTime:(CGFloat)time{
    value = MIN(MAX(0, value), time);
    [self.progressView setProgress:value/time animated:YES];
    self.timeLabel.text = [NSString stringWithFormat:@"%@ / %@", kPlayerConvertTime(value), kPlayerConvertTime(time)];
}

#pragma mark - lazy
- (UILabel *)timeLabel{
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.font = [UIFont systemFontOfSize:(13)];
        _timeLabel.textColor = UIColor.whiteColor;
        [self addSubview:_timeLabel];
    }
    return _timeLabel;
}
- (UIProgressView *)progressView{
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        [self addSubview:_progressView];
    }
    return _progressView;
}
@end
