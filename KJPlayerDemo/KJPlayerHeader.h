//
//  KJPlayerHeader.h
//  KJPlayerDemo
//
//  Created by 杨科军 on 2019/7/22.
//  Copyright © 2019 杨科军. All rights reserved.
//

#ifndef KJPlayerHeader_h
#define KJPlayerHeader_h

/** 作者信息
 *  Github地址：https://github.com/yangKJ
 *  简书地址：https://www.jianshu.com/u/c84c00476ab6
 *  博客地址：https://blog.csdn.net/qq_34534179
 
 ------------- 本人其他库 -------------
 播放器 - KJPlayer是一款视频播放器，AVPlayer的封装，继承UIView
 pod 'KJPlayer'  # 播放器功能区
 pod 'KJPlayer/KJPlayerView'  # 自带展示界面
 - 支持播放网络和本地视频、播放多种格式
 - 视频可以边下边播，把播放器播放过的数据流缓存到本地，下次直接从缓冲读取播放
 - 支持拖动、手势快进倒退、增大减小音量、重力感应切换横竖屏等等
 
 实用又方便的Category和一些自定义控件
 pod 'KJEmitterView'
 pod 'KJEmitterView/Function'#
 pod 'KJEmitterView/Control' # 自定义控件
 
 轮播图 - 支持缩放 多种pagecontrol 支持继承自定义样式 自带网络加载和缓存
 pod 'KJBannerView'  # 轮播图，网络图片加载
 
 菜单控件 - 下拉控件 选择控件
 pod 'KJMenuView' # 菜单控件
 
 加载Loading - 多种样式供选择
 pod 'KJLoadingAnimation' # 加载控件
 
 
 ####版本更新日志:
 
 #### Add 1.0.3
 1.增加播放类型功能 重复播放、随机播放、顺序播放、仅播放一次
 2.优化提高播放器稳定性和降低性能消耗
 3.新增 KJPlayerViewConfiguration 类用来管理设置默认属性
 4.完善全屏布局 完善 KJFastView 快进倒退展示区
 5.完成手势快进快退、手势改变音量、完成重力感应改变屏幕方向
 
 #### Add 1.0.2
 1.完善 KJPlayerView 展示界面
 2.修改bug
 
 #### Add 1.0.0
 1.第一次提交项目
 2.完善 KJPlayer 功能区

 */

/**
 #### KJPlayer
 
 - KJPlayerTool：主要提供一些播放器的工具  判断是否含有视频轨道  获取视频第一帧图片和总时长等等
 - KJRequestTask：网络缓存类   网络请求结束的时候，如果数据完整，则把数据缓存到指定的路径，储存起来，如果不完整，则删除缓存的临时文件数据
 - KJPlayerURLConnection：网络和Player的中转类   把网络请求缓存到本地的临时数据`offset`和`videoLength`传递给播放器
 
 ##### 代码事例
 ```
 UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 20, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width*9/16)];
 view.backgroundColor = UIColor.cyanColor;
 [self.view addSubview:view];
 
 NSURL *url = [NSURL URLWithString:@"https://mp4.vjshi.com/2018-03-30/1f36dd9819eeef0bc508414494d34ad9.mp4"];
 
 KJPlayer *player = [KJPlayer sharedInstance];
 player.playerDelegate = self;
 AVPlayerLayer *playerLayer = [player kj_playWithUrl:url];
 [player kj_seekToTime:player.videoTotalTime - 10];
 playerLayer.frame = view.bounds;
 [view.layer addSublayer:playerLayer];
 ```
 ##### 委托代理
 ```
 #pragma mark - KJPlayerDelegate
 - (void)kj_player:(nonnull KJPlayer *)player LoadedProgress:(CGFloat)loadedProgress LoadComplete:(BOOL)complete SaveSuccess:(BOOL)saveSuccess {
 NSLog(@"Load:%.2f==%d==%d",loadedProgress,complete,saveSuccess);
 }
 
 - (void)kj_player:(nonnull KJPlayer *)player Progress:(CGFloat)progress CurrentTime:(CGFloat)currentTime DurationTime:(CGFloat)durationTime {
 NSLog(@"Time:%.2f==%.2f==%.2f",progress,currentTime,durationTime);
 }
 
 - (void)kj_player:(nonnull KJPlayer *)player State:(KJPlayerState)state ErrorCode:(KJPlayerErrorCode)errorCode {
 NSLog(@"State:%ld==%ld",state,errorCode);
 }
 ```
 
 #### KPlayerView
 提供一套完整的布局界面，视图属性我全部暴露在外界，这样方便修改和重新布局
 直接 pod 'KJPlayer/KJPlayerView'  # 自带展示界面
 
 > KJPlayerViewConfiguration：配置信息
 > KJPlayerViewHeader：宏文件
 > KJLightView：亮度管理
 > KJFastView：快进倒退管理
 
 ##### 展示区代码事例
 ```
 @interface ViewController ()<KJPlayerViewDelegate>
 @property(nonatomic,strong) KJPlayerView *playerView;
 @end
 
 @implementation ViewController
 
 /// 电池状态栏管理
 - (BOOL)prefersStatusBarHidden{
 if (self.playerView) {
 return _playerView.configuration.fullScreen;
 }else{
 return NO;
 }
 }
 
 - (void)viewDidLoad {
 [super viewDidLoad];
 
 // Do any additional setup after loading the view.
 [self.view addSubview:self.playerView];
 }
 
 - (KJPlayerView*)playerView{
 if (!_playerView) {
 KJPlayerViewConfiguration *configuration = [[KJPlayerViewConfiguration alloc]init];
 configuration.autoHideTime = 0.0;
 configuration.playType = KJPlayerPlayTypeOrder;
 KJPlayerView *view = [[KJPlayerView alloc] initWithFrame:CGRectMake(0, 20, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width*9/16) Configuration:configuration];
 _playerView = view;
 view.backgroundColor = UIColor.blackColor;
 
 view.delegate = self;
 
 NSString *url = @"https://mp4.vjshi.com/2018-03-30/1f36dd9819eeef0bc508414494d34ad9.mp4";
 [view kj_setPlayWithURL:url StartTime:0];
 NSArray *temp = @[@"https://mp4.vjshi.com/2018-08-31/3ba67e58deb45fefe7f7d3d16dbf2b16.mp4",
 @"https://mp4.vjshi.com/2017-07-02/0cbbf21c6003f7936f4086dd10e7ebf5.mp4",
 [NSURL URLWithString:@"https://mp4.vjshi.com/2018-03-30/1f36dd9819eeef0bc508414494d34ad9.mp4"],
 ];
 view.videoUrlTemps = temp;
 view.videoIndex = 2;
 }
 return _playerView;
 }
 ```
 #### 委托代理
 ```
 #pragma mark - KJPlayerViewDelegate
 - (BOOL)kj_PlayerView:(KJPlayerView *)playerView DeviceDirection:(KJPlayerDeviceDirection)direction{
 /// 重置电池状态
 [self setNeedsStatusBarAppearanceUpdate];
 //    switch (direction) {
 //        case KJPlayerDeviceDirectionTop:
 //            playerView.layer.transform = CATransform3DIdentity;
 //            break;
 //        case KJPlayerDeviceDirectionBottom:
 //            playerView.layer.transform = CATransform3DIdentity;
 //            break;
 //        case KJPlayerDeviceDirectionLeft:
 //            playerView.layer.transform = CATransform3DMakeRotation(-M_PI/2, 0, 0, 1);
 //            playerView.layer.frame = CGRectMake(0, 0, PLAYER_SCREEN_WIDTH, PLAYER_SCREEN_HEIGHT);
 //            playerView.playerLayer.frame = playerView.bounds;
 //            break;
 //        case KJPlayerDeviceDirectionRight:
 //            playerView.layer.transform = CATransform3DMakeRotation(M_PI/2, 0, 0, 1);
 //            playerView.layer.frame = CGRectMake(0, 0, PLAYER_SCREEN_WIDTH, PLAYER_SCREEN_HEIGHT);
 //            break;
 //        default:
 //            break;
 //    }
 return NO;
 }
 
 ```
 */

/** 功能区
 *  支持播放网络和本地视频、播放多种格式
 *  视频可以边下边播，把播放器播放过的数据流缓存到本地
 *  下次直接优先从缓冲读取播放
 */
#import "KJPlayer.h"

#endif /* KJPlayerHeader_h */
