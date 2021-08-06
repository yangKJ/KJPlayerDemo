//
//  KJBaseUIPlayer.h
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/16.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo
//  播放器UI协议

#import "KJBasePlayerView.h"
#import "KJPlayerType.h"

@protocol KJBaseUIPlayer <NSObject>
@required
/// 播放器载体 
@property (nonatomic,strong) KJBasePlayerView *playerView;
/// 占位图 
@property (nonatomic,strong) UIImage *placeholder;
/// 背景颜色，默认黑色 
@property (nonatomic,assign) CGColorRef background;
/// 视频显示模式，默认 KJPlayerVideoGravityResizeAspect
@property (nonatomic,assign) KJPlayerVideoGravity videoGravity;
/// 获取当前截屏 
@property (nonatomic,copy,readonly) void (^kVideoTimeScreenshots)(void(^)(UIImage * image));
/// 子线程获取封面图，图片会存储在磁盘 
@property (nonatomic,copy,readonly) void(^kVideoPlaceholderImage)(void(^)(UIImage * image), NSURL *, NSTimeInterval);
/// 获取视频尺寸大小 
@property (nonatomic,copy,readwrite) void (^kVideoSize)(CGSize size);

#pragma mark - method
/// 列表上播放绑定tableView 
- (void)kj_bindTableView:(UITableView*)tableView indexPath:(NSIndexPath*)indexPath;

@end

// UI公共ivar
#define PLAYER_COMMON_UI_PROPERTY \
@synthesize playerView = _playerView;\
@synthesize placeholder = _placeholder;\
@synthesize background = _background;\
@synthesize videoGravity = _videoGravity;\
@synthesize kVideoSize = _kVideoSize;\
@dynamic kVideoTimeScreenshots;\
@dynamic kVideoPlaceholderImage;\
