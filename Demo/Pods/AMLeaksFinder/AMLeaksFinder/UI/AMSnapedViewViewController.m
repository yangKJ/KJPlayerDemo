//    MIT License
//
//    Copyright (c) 2020 梁大红
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy
//    of this software and associated documentation files (the "Software"), to deal
//    in the Software without restriction, including without limitation the rights
//    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//    copies of the Software, and to permit persons to whom the Software is
//    furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in all
//    copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//    SOFTWARE.

#import "AMLeaksFinder.h"

#ifdef __AUTO_MEMORY_LEAKS_FINDER_ENABLED__

#import "AMSnapedViewViewController.h"

@implementation AMSnapedViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGFloat width = self.snapedView.bounds.size.width * 0.5 > UIScreen.mainScreen.bounds.size.width / 2.0 ? UIScreen.mainScreen.bounds.size.width / 2.0 : self.snapedView.bounds.size.width * 0.5;
    CGFloat height = self.snapedView.bounds.size.height * 0.5 > UIScreen.mainScreen.bounds.size.height / 2.0 ? UIScreen.mainScreen.bounds.size.height / 2.0 : self.snapedView.bounds.size.height * 0.5;
    
    [self.view addSubview:self.snapedView];
    self.snapedView.translatesAutoresizingMaskIntoConstraints = NO;
    [[self.snapedView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor] setActive:YES];
    [[self.snapedView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor] setActive:YES];
    [[self.snapedView.widthAnchor constraintEqualToConstant:width] setActive:YES];
    [[self.snapedView.heightAnchor constraintEqualToConstant:height] setActive:YES];

    UILabel *topLabel = [UILabel new];
    topLabel.text = @"↓ 可能泄漏的 view ↓";
    [self.view addSubview:topLabel];
    topLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [[topLabel.centerXAnchor constraintEqualToAnchor:self.snapedView.centerXAnchor] setActive:YES];
    [[topLabel.bottomAnchor constraintEqualToAnchor:self.snapedView.topAnchor] setActive:YES];
    
    UILabel *bottomLabel = [UILabel new];
    bottomLabel.text = @"↑ 可能泄漏的 view ↑";
    [self.view addSubview:bottomLabel];
    bottomLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [[bottomLabel.centerXAnchor constraintEqualToAnchor:self.snapedView.centerXAnchor] setActive:YES];
    [[bottomLabel.topAnchor constraintEqualToAnchor:self.snapedView.bottomAnchor] setActive:YES];
        
    UIButton *button = [UIButton buttonWithType:(UIButtonTypeSystem)];
    [self.view addSubview:button];
    button.frame = CGRectMake(20, 60, 40, 30);
    [button setTitle:@"返回" forState:(UIControlStateNormal)];
    [button addTarget:self action:@selector(backButtonClick) forControlEvents:(UIControlEventTouchUpInside)];
}

- (void)backButtonClick {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

#endif
