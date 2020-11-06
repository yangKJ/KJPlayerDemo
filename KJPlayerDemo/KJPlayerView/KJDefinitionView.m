//
//  KJDefinitionView.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2019/9/9.
//  Copyright © 2019 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJDefinitionView.h"
#define PLAYER_BACK_WIDTH  (150)
@interface KJDefinitionView ()
@property(nonatomic,weak) UIViewController *saveVC;  // 保存父视图控制器
@property(nonatomic,strong) UIView *kSuperView;
@property(nonatomic,strong) UIView *backView;
@property(nonatomic,strong) NSMutableArray *names;
@property(nonatomic,assign) BOOL displayDefiniton;
@property(nonatomic,strong) KJPlayerViewModel *model;
@property(nonatomic,strong) KJPlayerViewConfiguration *configuration;
@property(nonatomic,copy,class) kDefinitionViewBlock xxblock; /// 类属性
@end

@implementation KJDefinitionView
static kDefinitionViewBlock _xxblock = nil;
+ (kDefinitionViewBlock)xxblock{
    if (_xxblock == nil) {
        _xxblock = ^void(KJPlayerViewModel *model){ };
    }
    return _xxblock;
}
+ (void)setXxblock:(kDefinitionViewBlock)xxblock{
    if (xxblock != _xxblock) _xxblock = [xxblock copy];
}
+ (instancetype)createDefinitionView:(KJPlayerViewModel*(^_Nullable)(KJDefinitionView *obj))block ModelBlock:(kDefinitionViewBlock)modelBlock{
    KJDefinitionView *view = [[KJDefinitionView alloc] initWithFrame:CGRectMake(0, 0, PLAYER_SCREEN_HEIGHT, PLAYER_SCREEN_WIDTH)];
    view.backgroundColor = UIColor.clearColor;
    [view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:view action:@selector(kDismiss)]];
    [view config];
    if (block) view.model = block(view);
    [view setUI];
    self.xxblock = modelBlock;
    return view;
}
- (void)config{
    self.names = [NSMutableArray array];
    self.displayDefiniton = NO;
    self.kSuperView = [UIApplication sharedApplication].windows[0];
}
- (void)setUI{
    [self.kSuperView addSubview:self];
    [self addSubview:self.backView];
    [self kDisplay];
}
- (UIView*)backView{
    if (!_backView) {
        _backView = [[UIView alloc]initWithFrame:CGRectMake(PLAYER_SCREEN_HEIGHT-PLAYER_BACK_WIDTH, 0, PLAYER_BACK_WIDTH, PLAYER_SCREEN_WIDTH)];
        _backView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    }
    return _backView;
}
- (void)kDisplay{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.duration = 0.2;
    animation.repeatCount = 1;
    animation.fromValue = [NSValue valueWithCGPoint:CGPointMake(PLAYER_SCREEN_HEIGHT+PLAYER_BACK_WIDTH*.5,PLAYER_SCREEN_WIDTH*.5)];
    animation.toValue   = [NSValue valueWithCGPoint:CGPointMake(PLAYER_SCREEN_HEIGHT-PLAYER_BACK_WIDTH*.5,PLAYER_SCREEN_WIDTH*.5)];
    [self.backView.layer addAnimation:animation forKey:@"move-layer"];
}
/// 视图消失
- (void)kDismiss{
    self.displayDefiniton = NO;
    [UIView animateWithDuration:0.2 animations:^{
        self.backView.frame = CGRectMake(PLAYER_SCREEN_HEIGHT, 0, PLAYER_BACK_WIDTH, PLAYER_SCREEN_WIDTH);
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}
- (KJDefinitionView *(^)(UIViewController *))KJSuperViewController {
    return ^(UIViewController *vc) {
        self.saveVC = vc;
        return self;
    };
}
- (KJDefinitionView *(^)(KJPlayerViewConfiguration *))KJConfiguration {
    return ^(KJPlayerViewConfiguration *configuration){
       self.configuration = configuration;
       return self;
    };
}
- (KJDefinitionView *(^)(UIView *))KJAddView {
    return ^(UIView *addView){
       self.kSuperView = addView;
       return self;
    };
}
#pragma mark - setter
- (void)setModel:(KJPlayerViewModel *)model{
    if (model == nil) return;
    _model = model;
    self.displayDefiniton = YES;
    [self.names removeAllObjects];
    if (model.sd) [_names addObject:KJPlayerViewModelPriorityTypeStringMap[KJPlayerViewModelPriorityTypeSD]];
    if (model.cif)[_names addObject:KJPlayerViewModelPriorityTypeStringMap[KJPlayerViewModelPriorityTypeCIF]];
    if (model.hd) [_names addObject:KJPlayerViewModelPriorityTypeStringMap[KJPlayerViewModelPriorityTypeHD]];
    for (NSInteger i=0; i<_names.count; i++) {
        CGFloat mask = 15;
        CGFloat w = 80;
        CGFloat h = 30;
        CGFloat x = 35;
        CGFloat y = 51 + (h+mask)*i;
        UIButton *button = [UIButton buttonWithType:(UIButtonTypeCustom)];
        button.frame = CGRectMake(x, y, w, h);
        [button setTitle:_names[i] forState:(UIControlStateNormal)];
        if ([_names[i] isEqualToString:KJPlayerViewModelPriorityTypeStringMap[model.priorityType]]) {
            button.layer.borderColor = self.configuration.mainColor.CGColor;
            [button setTitleColor:self.configuration.mainColor forState:(UIControlStateNormal)];
        }else{
            button.layer.borderColor = PLAYER_UIColorFromHEXA(0xCCCCCC,1).CGColor;
            [button setTitleColor:PLAYER_UIColorFromHEXA(0xCCCCCC,1) forState:(UIControlStateNormal)];
        }
        button.layer.borderWidth = 1.0;
        button.layer.cornerRadius = 3;
        button.layer.masksToBounds = YES;
        button.tag = 520 + i;
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:(UIControlEventTouchUpInside)];
        [self.backView addSubview:button];
    }
}

- (void)buttonAction:(UIButton*)sender{
    NSString *name = self.names[sender.tag - 520];
    if ([name isEqualToString:KJPlayerViewModelPriorityTypeStringMap[KJPlayerViewModelPriorityTypeSD]]) {
        if (_model.priorityType == KJPlayerViewModelPriorityTypeSD) return;
        _model.priorityType = KJPlayerViewModelPriorityTypeSD;
    }else if ([name isEqualToString:KJPlayerViewModelPriorityTypeStringMap[KJPlayerViewModelPriorityTypeCIF]]) {
        if (_model.priorityType == KJPlayerViewModelPriorityTypeCIF) return;
        _model.priorityType = KJPlayerViewModelPriorityTypeCIF;
    }else if ([name isEqualToString:KJPlayerViewModelPriorityTypeStringMap[KJPlayerViewModelPriorityTypeHD]]) {
        if (_model.priorityType == KJPlayerViewModelPriorityTypeHD) return;
        _model.priorityType = KJPlayerViewModelPriorityTypeHD;
    }
    _xxblock(_model);
    [self kDismiss];
}

@end
