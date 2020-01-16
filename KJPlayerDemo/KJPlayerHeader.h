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
 - 视频可以边下边播，把播放器播放过的数据流缓存到本地，下次直接从缓冲读取播放
 pod 'KJPlayer'  # 播放器功能区
 pod 'KJPlayer/KJPlayerView'  # 自带展示界面
 
 - 粒子效果、Button图文混排、点击事件封装、扩大点击域、点赞粒子效果，
 - 手势封装、圆角渐变、Xib属性、TextView输入框扩展、限制字数、识别网址超链接，
 - Image图片加工处理、滤镜渲染、泛洪算法等等
 pod 'KJEmitterView'
 pod 'KJEmitterView/Function'#
 pod 'KJEmitterView/Control' # 自定义控件
 
 轮播图 - 支持缩放 多种pagecontrol 支持继承自定义样式 自带网络加载和缓存
 pod 'KJBannerView'  # 轮播图，网络图片加载 支持网络GIF和网络图片和本地图片混合轮播
 
 加载Loading - 多种样式供选择 HUD控件封装
 pod 'KJLoadingAnimation' # 加载控件
 
 菜单控件 - 下拉控件 选择控件
 pod 'KJMenuView' # 菜单控件
 
 工具库 - 推送工具、网络下载工具、识别网页图片工具等
 pod 'KJWorkbox' # 系统工具
 pod 'KJWorkbox/CommonBox'
 
 ####版本更新日志:
 #### Add 1.0.8
 1.引入头文件 KJPlayerHeader
 2.修复切换视频清晰度之后从头播放
 3.扩大按钮点击域KJPlayerButtonTouchAreaInsets
 
 #### Add 1.0.6
 1.重构KJDefinitionView清晰度面板
 2.配置信息类KJPlayerViewConfiguration新增属性 continuePlayWhenAppReception 控制是否后台返回播放
 3.工具类KJPlayerTool 新增 kj_playerValidateUrl 判断当前URL是否可用
 
 #### Add 1.0.5
 1.重新更新KJPlayer播放方式
 2.新增清晰度选择
 
 #### Add 1.0.4
 1.新增 KJFileOperation 文件操作类
 2.KJPlayerView 重新布局添加控件
 3.修复不能播放长视频BUG
 
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

- KJPlayerTool:主要提供一些播放器的工具 判断是否含有视频轨道  获取视频第一帧图片和总时长等等
- KJRequestTask:网络缓存类 网络请求结束的时候，如果数据完整，则把数据缓存到指定的路径，储存起来，如果不完整，则删除缓存的临时文件数据
- KJPlayerURLConnection:网络和Player的中转类 把网络请求缓存到本地的临时数据`offset`和`videoLength`传递给播放器

##### 代码事例
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
 
##### 委托代理
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

#### KPlayerView
提供一套完整的布局界面，视图属性我全部暴露在外界，这样方便修改和重新布局
直接 pod 'KJPlayer/KJPlayerView'  # 自带展示界面

> KJPlayerViewConfiguration:配置信息
> KJPlayerViewHeader:宏文件
> KJLightView:亮度管理
> KJFastView:快进倒退管理
> KJDefinitionView:清晰度展示面板

 #### 获取当前播放视频地址的算法
 如果你们需要不同的算法方式，请修改就完事

 ```
 /// 得到当前播放的视频地址
 - (NSString*)kj_getCurrentURL{
     return ({
         NSString *name;
         switch (_videoModel.priorityType) {
             case KJPlayerViewModelPriorityTypeSD:
                 name = kj_getPlayURL(_videoModel.sd,_videoModel.cif,_videoModel.hd);
                 break;
             case KJPlayerViewModelPriorityTypeCIF:
                 name = kj_getPlayURL(_videoModel.cif,_videoModel.sd,_videoModel.hd);
                 break;
             case KJPlayerViewModelPriorityTypeHD:
                 name = kj_getPlayURL(_videoModel.hd,_videoModel.cif,_videoModel.sd);
                 break;
             default:
                 break;
         }
         name;
     });
 }

 static inline NSString * kj_getPlayURL(NSString*x,NSString*y,NSString*z){
     return (x || y) == 0 ? z : (x?:y);
 }
 ```
 
##### 展示区代码事例
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

     NSArray *temp = @[@"https:apps.winpow.com/attached/media/mp4/1559550527183.mp4",
                     @"http:appit.winpow.com/attached/media/MP4/1567585643618.mp4",
                     @"https:devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_4x3/gear1/prog_index.m3u8",
                     @"https:mp4.vjshi.com/2018-08-31/3ba67e58deb45fefe7f7d3d16dbf2b16.mp4",
                     @"https:mp4.vjshi.com/2017-07-02/0cbbf21c6003f7936f4086dd10e7ebf5.mp4",
                     @"https:mp4.vjshi.com/2018-03-30/1f36dd9819eeef0bc508414494d34ad9.mp4",
                     ];
     NSMutableArray *array = [NSMutableArray array];
     for (NSInteger i=0; i<2; i++) {
     KJPlayerViewModel *model = [KJPlayerViewModel new];
         if (i==0) {
             model.sd = temp[0];
             model.cif = temp[1];
         }else if (i==1) {
             model.hd = temp[2];
         }else{
             model.sd = temp[3];
             model.hd = temp[4];
         }
         [array addObject:model];
     }
     view.videoIndex = 0;
     view.videoModelTemps = array;
 }
 return _playerView;
}
 
#### 委托代理
#pragma mark - KJPlayerViewDelegate
- (BOOL)kj_PlayerView:(KJPlayerView *)playerView DeviceDirection:(KJPlayerDeviceDirection)direction{
    /// 重置电池状态
    [self setNeedsStatusBarAppearanceUpdate];
    return NO;
}
/// Bottom按钮事件  tag:520收藏、521下载、522清晰度
- (void)kj_PlayerView:(KJPlayerView*)playerView BottomButton:(UIButton*)sender{
 
}
*/

/** 功能区
 *  支持播放网络和本地视频、播放多种格式
 *  视频可以边下边播，把播放器播放过的数据流缓存到本地
 *  下次直接优先从缓冲读取播放
 */
#import "KJPlayer.h"

//#import "KJPlayerView.h" /// 提供一套布局

#endif /* KJPlayerHeader_h */
