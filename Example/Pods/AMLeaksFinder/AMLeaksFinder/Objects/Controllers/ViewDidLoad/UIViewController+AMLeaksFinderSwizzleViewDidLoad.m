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

#import <UIKit/UIKit.h>
#import "UIViewController+AMLeaksFinderUI.h"
#import "UIViewController+AMLeaksFinderTools.h"
#import "AMMemoryLeakModel.h"
#import <objc/runtime.h>

static const void * const associatedKey = &associatedKey;

@implementation UIViewController (AMLeaksFinderSwizzleViewDidLoad)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        am_fi_sw_in_me(self.class,
                       @selector(viewDidLoad),
                       @selector(amleaks_finder_viewDidLoad));
        
        am_fi_sw_in_me(self.class,
                       @selector(viewDidAppear:),
                       @selector(amleaks_finder_viewDidAppear:));
        
    });
}

- (void)amleaks_finder_viewDidLoad {
    [self amleaks_finder_viewDidLoad];
    AMMemoryLeakDeallocModel *deallocModel = objc_getAssociatedObject(self, associatedKey);
    if (deallocModel) {
        return;
    }
    
    // 绑定 deallocModel, 监控 dealloc 方法
    deallocModel = AMMemoryLeakDeallocModel.new;
    objc_setAssociatedObject(self, associatedKey, deallocModel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    deallocModel.controller = self;
    
    // 绑定 AMMemoryLeakModel
    AMMemoryLeakModel *memoryLeakModel = AMMemoryLeakModel.new;
    memoryLeakModel.memoryLeakDeallocModel = deallocModel;
    [UIViewController.memoryLeakModelArray insertObject:memoryLeakModel atIndex:0];
    
    // 刷新 UI
    [UIViewController udpateUI];
}

- (void)amleaks_finder_viewDidAppear:(BOOL)animated {
    [self amleaks_finder_viewDidAppear:animated];
    [self amleaks_finder_normal];
}

@end

#endif
