//
//  KJBasePlayer+KJDynamicSource.m
//  KJPlayer
//
//  Created by yangkejun on 2021/8/17.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJBasePlayer+KJDynamicSource.h"

@interface KJBasePlayer ()

/// 上个内核名称
@property (nonatomic,strong) NSString *lastSourceName;

@end

@implementation KJBasePlayer (KJDynamicSource)

#pragma mark - 动态切换板块

/// 动态切换播放内核
- (void)kj_dynamicChangeSourcePlayer:(Class)clazz{
    NSString *__name = NSStringFromClass([self class]);
    kPlayerPerformSel(self, @"kj_changeSourceCleanJobs");
    object_setClass(self, clazz);
    if ([__name isEqualToString:self.lastSourceName]) {
        return;
    } else {
        self.lastSourceName = __name;
    }
    if ([__name isEqualToString:@"KJAVPlayer"]) {
        [self setValue:nil forKey:@"tempView"];
    }else if ([__name isEqualToString:@"KJIJKPlayer"]) {
        [self setValue:nil forKey:@"playerOutput"];
        [self setValue:nil forKey:@"playerLayer"];
    }else if ([__name isEqualToString:@"KJMIDIPlayer"]) {

    }
}
/// 是否进行过动态切换内核
- (BOOL(^)(void))kPlayerDynamicChangeSource{
    return ^BOOL{
        if (self.lastSourceName == nil || !self.lastSourceName.length) {
            return NO;
        }
        return ![self.lastSourceName isEqualToString:NSStringFromClass([self class])];
    };
}
/// 当前播放器内核名
- (NSString * (^)(void))kPlayerCurrentSourceName{
    return ^NSString * {
        NSString *name = NSStringFromClass([self class]);
        if ([name isEqualToString:@"KJAVPlayer"]) {
            return @"AVPlayer";
        }
        if ([name isEqualToString:@"KJIJKPlayer"]) {
            return @"IJKPlayer";
        }
        if ([name isEqualToString:@"KJMIDIPlayer"]) {
            return @"midi";
        }
        return @"Unknown";
    };
}

#pragma mark - Associated

- (NSString *)lastSourceName{
    return objc_getAssociatedObject(self, _cmd);;
}
- (void)setLastSourceName:(NSString *)lastSourceName{
    objc_setAssociatedObject(self, @selector(lastSourceName), lastSourceName, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end
