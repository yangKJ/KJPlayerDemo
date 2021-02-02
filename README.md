# KJPlayer

#### <a id="功能介绍"></a>功能介绍
KJPlayer 是一款视频播放器，AVPlayer的封装，继承UIView    
1.支持播放网络和本地视频  ☑️  
2.播放多种格式mp4  ☑️  m3u8、3gp、mov等等暂未完成  
3.视频边播边下，缓存完成视频保存本地  ☑️  
4.缓存离线观看  ☑️    
5.重力感应切换横竖屏  ☑️  
6.手势滑动改变播放进度和音量和亮度  ☑️  
7.视频支持播放完之后播放下一集  ☑️  
8.随机播放、顺序播放、重复播放  ☑️  
9.小窗口播放、锁定控制面板等等  
10.缓存管理、清除长时间不再观看的视频  
11.免费试看几分钟  
12.音频功能  
13.音频和视频混合播放  

----------------------------------------
### 框架整体介绍
* [功能介绍](#功能介绍)
* [更新日志](#更新日志)
* [效果图](#效果图)
* [KJPlayer 功能区](#KJPlayer)
* [KJPlayerView 展示区](#KJPlayerView)
* [打赏作者 &radic;](#打赏作者)

#### <a id="使用方法(支持cocoapods/carthage安装)"></a>Pod使用方法
```
pod 'KJPlayer' # 播放器功能区
pod 'KJPlayer/KJPlayerView' # 自带展示界面
```

#### <a id="更新日志"></a>更新日志
```
####版本更新日志:
#### Add 1.0.9
1.重新整理，移除不再使用数据
2.重写播放器内核 KJPlayer

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
```

#### <a id="效果图"></a>效果图
横屏展示效果图：

![培训活动-视频全屏](https://upload-images.jianshu.io/upload_images/1933747-3d64de1b9d073891.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

竖屏目前展示效果：

![WechatIMG10.jpeg](https://upload-images.jianshu.io/upload_images/1933747-537dbd09082b0153.jpeg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

#### <a id="KJPlayer"></a>KJPlayer

