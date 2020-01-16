//
//  UIButton+KJPlayerButtonTouchAreaInsets.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2020/1/6.
//  Copyright © 2020 杨科军. All rights reserved.
//

#import "UIButton+KJPlayerButtonTouchAreaInsets.h"
#import <objc/runtime.h>
@implementation UIButton (KJPlayerButtonTouchAreaInsets)
- (UIEdgeInsets)touchAreaInsets{
    return [objc_getAssociatedObject(self, @selector(touchAreaInsets)) UIEdgeInsetsValue];
}
- (void)setTouchAreaInsets:(UIEdgeInsets)touchAreaInsets{
    NSValue *value = [NSValue valueWithUIEdgeInsets:touchAreaInsets];
    objc_setAssociatedObject(self, @selector(touchAreaInsets), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    UIEdgeInsets touchAreaInsets = self.touchAreaInsets;
    CGRect bounds = self.bounds;
    bounds = CGRectMake(bounds.origin.x - touchAreaInsets.left,
                        bounds.origin.y - touchAreaInsets.top,
                        bounds.size.width + touchAreaInsets.left + touchAreaInsets.right,
                        bounds.size.height + touchAreaInsets.top + touchAreaInsets.bottom);
    return CGRectContainsPoint(bounds, point);
}

@end
