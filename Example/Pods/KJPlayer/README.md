# KJPlayer
[![Language](https://img.shields.io/badge/Language-%20Objective%20C%20-blue.svg)](https://github.com/yangKJ/KJPlayerDemo)

----------------------------------------
KJPlayer 是一款视频播放器，AVPlayer的封装，继承UIView  
后续功能：  
1.缓存离线观看  
2.免费试看几分钟  
3.视频支持重力感应、手势滑动、小窗口播放、锁屏等等  
4.视频支持播放完之后播放下一集  
5.随机播放、顺序播放  
6.缓存管理、清除长时间不再观看的视频  
7.音频功能  
8.音频和视频混合播放  

----------------------------------------
#### 温馨提示
使用第三方库Xcode报错  
Cannot synthesize weak property because the current deployment target does not support weak references  
可在`Podfile`文件底下加入下面的代码，'8.0'是对应的部署目标（deployment target） 删除库重新Pod  
不支持用weak修饰属性，而weak在使用ARC管理引用计数项目中才可使用  
遍历每个develop target，将target支持版本统一设成一个支持ARC的版本

```
##################加入代码##################
# 使用第三方库xcode报错Cannot synthesize weak property because the current deployment target does not support weak references
post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] ='8.0'
        end
    end
end
##################加入代码##################
```

----------------------------------------
### 框架整体介绍
* [作者信息](#作者信息)
* [作者其他库](#作者其他库)
* [功能介绍](#功能介绍)
* [Pod使用方法](#使用方法(支持cocoapods/carthage安装))
* [更新日志](#更新日志)
* [效果图](#效果图)

#### <a id="作者信息"></a>作者信息
> Github地址：https://github.com/yangKJ  
> 简书地址：https://www.jianshu.com/u/c84c00476ab6  
> 博客地址：https://blog.csdn.net/qq_34534179  


#### <a id="作者其他库"></a>作者其他Pod库
```
播放器 - KJPlayer是一款视频播放器，AVPlayer的封装，继承UIView
- 支持播放网络和本地视频、播放多种格式
- 视频可以边下边播，把播放器播放过的数据流缓存到本地，下次直接从缓冲读取播放
- 支持拖动、手势快进倒退、增大减小音量、重力感应切换横竖屏等等
pod 'KJPlayer'  # 播放器功能区
pod 'KJPlayer/KJPlayerView'  # 自带展示界面

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

```

#### <a id="功能介绍"></a>功能介绍
- [x] 支持播放网络和本地视频
- [x] 支持播放多种格式mp4、m3u8、3gp、mov等等
- [x] 视频可以边下边播，把播放器播放过的数据流缓存到本地，下次直接从缓冲读取播放
- [x] 支持拖动、手势快进倒退、增大减小音量等等
- [x] 支持重力感应切换横竖屏

###
下载完Demo请执行`carthage update --platform iOS`

##### Feature
如果您在使用中有好的需求及建议，或者遇到什么bug，欢迎随时issue，我会及时的回复，有空也会不断优化更新这些库。

#### <a id="使用方法(支持cocoapods/carthage安装)"></a>Pod使用方法
```
pod 'KJPlayer'  # 播放器功能区
pod 'KJPlayer/KJPlayerView'  # 自带展示界面
```

#### <a id="更新日志"></a>更新日志
```
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
```

#### <a id="效果图"></a>效果图
竖屏目前展示效果：

![WechatIMG9.png](https://upload-images.jianshu.io/upload_images/1933747-c350cda7cc17265b.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


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

