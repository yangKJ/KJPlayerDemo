//
//  KJDefinitionView.h
//  KJPlayerDemo
//
//  Created by 杨科军 on 2019/9/9.
//  Copyright © 2019 杨科军. All rights reserved.
//  清晰度面板

#import <UIKit/UIKit.h>
#import "KJPlayerViewModel.h"
#import "KJPlayerViewHeader.h"
#import "KJPlayerViewConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^kDefinitionViewBlock)(KJPlayerViewModel *model);
@interface KJDefinitionView : UIView
// 初始化
+ (instancetype)createDefinitionView:(KJPlayerViewModel*(^_Nullable)(KJDefinitionView *obj))block ModelBlock:(kDefinitionViewBlock)modelBlock;
// 保存父视图控制器
@property(nonatomic,weak,readonly)   KJDefinitionView *(^KJSuperViewController)(UIViewController*);
@property(nonatomic,strong,readonly) KJDefinitionView *(^KJConfiguration)(KJPlayerViewConfiguration*);
@property(nonatomic,strong,readonly) KJDefinitionView *(^KJAddView)(UIView *);
/** 清晰度面板是否正在显示 */
@property(nonatomic,assign,readonly) BOOL displayDefiniton;
/// 视图消失
- (void)kDismiss;
@end

NS_ASSUME_NONNULL_END
