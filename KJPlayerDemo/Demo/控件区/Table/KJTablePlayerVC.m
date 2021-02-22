//
//  KJTablePlayerVC.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/9.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJTablePlayerVC.h"
#import "KJPlayer.h"
#import "KJDetailPlayerVC.h"
@interface KJTableViewInfo : NSObject
@property(nonatomic,strong)NSString *url;
@property(nonatomic,strong)UIImage *image;
@end
@interface KJTableViewCell : UITableViewCell
@property(nonatomic,strong)KJBasePlayerView *videoImageView;
@property(nonatomic,strong)UILabel *label;
@property(nonatomic,strong)UIActivityIndicatorView *loadingView;
@property(nonatomic,copy,readwrite) void(^kTabBlock)(KJTableViewCell *item, NSInteger index);
@end
@interface KJTablePlayerVC ()<UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, KJPlayerDelegate>
@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,strong)NSArray *temps;
@property(nonatomic,assign)NSInteger index;
@end

@implementation KJTablePlayerVC
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;
    NSArray *temps = @[@"https://mp4.vjshi.com/2017-11-21/7c2b143eeb27d9f2bf98c4ab03360cfe.mp4",
                       @"https://mp4.vjshi.com/2020-12-01/bc8b1a8d9166d2040bd8946ad6447235.mp4",
                       @"https://mp4.vjshi.com/2020-09-27/542926a8c2a99808fc981d46c1dc6aef.mp4",
                       @"https://mp4.vjshi.com/2017-05-12/f7f9ecfebb7d5fe78f4f768c86b3a552.mp4",
                       @"https://mp4.vjshi.com/2021-01-13/d37b7bea25b063b4f9d4bdd98bc611e3.mp4",
                       @"https://mp4.vjshi.com/2017-06-03/076f1b8201773231ca2f65e38c34033c.mp4",
                       @"https://mp4.vjshi.com/2021-01-13/ac721f0590f0b0509092afea52d55a90.mp4",
                       @"https://mp4.vjshi.com/2018-03-30/1f36dd9819eeef0bc508414494d34ad9.mp4",
                       @"https://mp4.vjshi.com/2016-09-03/72808b798d42dbca8d901b97e3bb54f4.mp4",
                       @"https://mp4.vjshi.com/2020-07-05/ef748e3a0077c8cc7c3d9a529d201beb.mp4",
                       @"http://appit.winpow.com/attached/media/MP4/1567585643618.mp4",
    ];
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:temps.count];
    for (NSString *url in temps) {
        KJTableViewInfo *info = [KJTableViewInfo new];
        info.url = url;
        [array addObject:info];
    }
//    [KJCachePlayerManager kj_clearVideoCoverImageWithURL:[NSURL URLWithString:temps[1]]];
//    [KJCachePlayerManager kj_clearAllVideoCoverImage];
    
    self.temps = array.mutableCopy;
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, PLAYER_STATUSBAR_NAVIGATION_HEIGHT, self.view.bounds.size.width, 40)];
    [self.view addSubview:label];
    label.textAlignment = 1;
    label.text = @"点击网址无缝衔接跳转至详情页面控制器";
    label.textColor = [UIColor.redColor colorWithAlphaComponent:0.7];
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 40+PLAYER_STATUSBAR_NAVIGATION_HEIGHT, self.view.bounds.size.width, self.view.bounds.size.height-40-PLAYER_STATUSBAR_NAVIGATION_HEIGHT-PLAYER_BOTTOM_SPACE_HEIGHT) style:UITableViewStylePlain];
    self.tableView = tableView;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.rowHeight = self.view.frame.size.width;
    [tableView registerClass:[KJTableViewCell class] forCellReuseIdentifier:@"KJTableViewCell"];
    [self.view addSubview:tableView];
}

- (void)dealloc{
    [KJPlayer.shared kj_stop];
    [KJPlayer kj_attempDealloc];
}
#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.temps count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    KJTableViewCell *cell = [[KJTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"KJTableViewCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    KJTableViewInfo *info = self.temps[indexPath.row];
    cell.label.text = info.url;
    cell.videoImageView.tag = 520 + indexPath.row;
    if (info.image == nil) {
        KJPlayer.shared.kVideoPlaceholderImage(^(UIImage * _Nonnull image) {
            if (image == nil) {
                image = [UIImage imageNamed:@"20ea53a47eb0447883ed186d9f11e410"];
            }
            cell.videoImageView.image = image;
            info.image = image;
        }, [NSURL URLWithString:cell.label.text], 8);
    }else{
        if (self.index == indexPath.row) {
            [cell.videoImageView.layer addSublayer:KJPlayer.shared.playerLayer];
        }
        cell.videoImageView.image = info.image;
    }
    PLAYER_WEAKSELF;
    cell.kTabBlock = ^(KJTableViewCell *item, NSInteger index) {
        if (weakself.index == index) {
            if (KJPlayer.shared.isPlaying) {
                [KJPlayer.shared kj_pause];
                return;
            }else if (KJPlayer.shared.userPause) {
                [KJPlayer.shared kj_resume];
                return;
            }
        }
        weakself.index = index;
        KJPlayer.shared.playerView = item.videoImageView;
        KJPlayer.shared.placeholder = item.videoImageView.image;
        KJPlayer.shared.delegate = weakself;
        KJPlayer.shared.cacheTime = 0;
        KJPlayer.shared.videoURL = [NSURL URLWithString:item.label.text];
    };
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.index != indexPath.row) {
        return;
    }
    KJDetailPlayerVC *vc = [KJDetailPlayerVC new];
    vc.layer = KJPlayer.shared.playerLayer;
    vc.kBackBlock = ^{
        KJTableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.index inSection:0]];
        KJPlayer.shared.playerLayer.frame = cell.videoImageView.bounds;
        [cell.videoImageView.layer addSublayer:KJPlayer.shared.playerLayer];
    };
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([scrollView isEqual:self.tableView]) {
//        [_player playerScrollIsSupportSmallWindowPlay:YES];
    }
}
#pragma mark - KJPlayerDelegate
/* 当前播放器状态 */
- (void)kj_player:(KJBasePlayer*)player state:(KJPlayerState)state{
    NSLog(@"---当前播放器状态:%@",KJPlayerStateStringMap[state]);
    if (state == KJPlayerStatePlayFinished) {
        [player kj_replay];
    }
    KJTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.index inSection:0]];
    if (state == KJPlayerStateBuffering || state == KJPlayerStatePausing) {
        [cell.loadingView startAnimating];
    }else if (state == KJPlayerStatePreparePlay || state == KJPlayerStatePlaying) {
        [cell.loadingView stopAnimating];
    }
}
/* 播放进度 */
- (void)kj_player:(KJBasePlayer*)player currentTime:(NSTimeInterval)time{
//    NSLog(@"---播放进度:%.2f,%.2f",time,total);
}
/* 缓存进度 */
- (void)kj_player:(KJBasePlayer*)player loadProgress:(CGFloat)progress{
    NSLog(@"---缓存进度:%f",progress);
}

@end
@implementation KJTableViewCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self){
        self.videoImageView = [[KJBasePlayerView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width-50)];
        self.videoImageView.userInteractionEnabled = YES;
        self.videoImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.videoImageView.backgroundColor = UIColor.blackColor;
        [self.contentView addSubview:self.videoImageView];
        self.label = [[UILabel alloc]initWithFrame:CGRectMake(10, [UIScreen mainScreen].bounds.size.width-50, [UIScreen mainScreen].bounds.size.width-20, 50)];
        self.label.textColor = [UIColor.blueColor colorWithAlphaComponent:0.8];
        self.label.numberOfLines = 0;
        [self.contentView addSubview:self.label];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapVideoPlayer:)];
        [self.videoImageView addGestureRecognizer:tap];
        self.loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        self.loadingView.center = CGPointMake(self.videoImageView.frame.size.width/2, self.videoImageView.frame.size.height/2);
        CGAffineTransform transform = CGAffineTransformMakeScale(1.5, 1.5);
        _loadingView.transform = transform;
        [self.contentView addSubview:self.loadingView];
    }
    return self;
}
- (void)tapVideoPlayer:(UITapGestureRecognizer *)tapGesture{
    if (self.kTabBlock) {
        self.kTabBlock(self, tapGesture.view.tag - 520);
    }
}
@end
@implementation KJTableViewInfo

@end
