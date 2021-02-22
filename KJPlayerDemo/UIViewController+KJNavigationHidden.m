//
//  UIViewController+KJNavigationHidden.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/22.
//  Copyright © 2021 杨科军. All rights reserved.
//

#import "UIViewController+KJNavigationHidden.h"

@implementation UIViewController (KJNavigationHidden)
- (void)navigationController:(UINavigationController*)navigationController willShowViewController:(UIViewController*)viewController animated:(BOOL)animated {
    if (viewController == self){
        [navigationController setNavigationBarHidden:YES animated:YES];
    }else{
        if ([navigationController isKindOfClass:[UIImagePickerController class]]) {
            return;
        }
        [navigationController setNavigationBarHidden:NO animated:YES];
        if (navigationController.delegate == self){
            navigationController.delegate = nil;
        }
    }
}

@end
