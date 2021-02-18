//
//  KJDetailPlayerVC.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/9.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJDetailPlayerVC.h"
@interface KJDetailPlayerVC ()
@property(nonatomic,strong)UIView *playerView;
@end

@implementation KJDetailPlayerVC
- (void)willMoveToParentViewController:(UIViewController*)parent{
    [super willMoveToParentViewController:parent];
}
- (void)didMoveToParentViewController:(UIViewController*)parent{
    [super didMoveToParentViewController:parent];
    //侧滑返回监听
    if(parent == nil){
        if (self.kBackBlock) {
            self.kBackBlock();
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (void)backItemClick{
    if (self.kBackBlock) {
        self.kBackBlock();
    }
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;
    UIButton *backButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 20, 40)];
    [backButton setImage:[UIImage imageNamed:@"Arrow"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backItemClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backItem;
    
    [self.view addSubview:self.playerView];
    if (self.layer) {
        self.layer.frame = self.playerView.bounds;
        [self.playerView.layer addSublayer:self.layer];
    }
}
- (UIView *)playerView{
    if (!_playerView) {
        _playerView = [[UIView alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.width*9/16)];
//        _playerView.center = self.view.center;
        _playerView.backgroundColor = UIColor.blackColor;
    }
    return _playerView;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
