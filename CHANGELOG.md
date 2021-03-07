
### 作者信息
### [Github地址](https://github.com/yangKJ) | [简书地址](https://www.jianshu.com/u/c84c00476ab6) | [博客地址](https://blog.csdn.net/qq_34534179) | [掘金地址](https://juejin.cn/user/1987535102554472/posts)

> 备注：快捷打开浏览器命令，command + shift + 鼠标左键

### 版本更新日志
```
####版本更新日志:
#### Add 2.1.3
1.继续完善IJKPlyer内核，修复问题
2.分离AVPlayer内核的边下边播边存分支，请使用 pod 'KJPlayer/AVDownloader'
3.整理删除重复和无用代码，优化试看逻辑处理
4.异步子线程获取上次播放时间，优化性能

#### Add 2.1.2
1.新增 KJIJKPlayer内核，完善基本播放流媒体功能
2.分离委托协议至 KJPlayerProtocol
3.修复 KJAVPlayer 内核当中的截取HLS图片失败问题
4.初步完成动态切换内核操作，kj_changeSourcePlayer:

#### Add 2.1.1
1.优化 AVPlayer内核播放文件类型
2.修复全屏控件坐标错位问题
3.新增顶部底部操作面板，自动隐藏和手势隐藏操功能
4.优化全屏/半屏

#### Add 2.1.0
1.新增KJRotateManager全屏/半屏管理
2.新增字体图标使用
3.完善之前的逻辑处理

#### Add 2.0.2
1.KJBasePlayerView 新增手势管理 单击/双击/长按
2.处理快进手势，音量手势，亮度手势
3.修复载体 center 发生变化闪退问题
4.新增进度和音量/亮度Layer控件
5.修复切换源之后加载指示器/文本提示框消失问题
6.分离加载动画和文本提示框

#### Add 2.0.1
1.分离缓存播放 KJAVPlayer+KJCache
2.修改重写网络请求板块，实现断点续载续播功能
3.新增播放器控件基类 KJBasePlayerView
4.数据库新增上次播放时间，缓存完成与否等字段
5.新增圆圈动画加载，支持富文本的提示框
6.新增记录播放和跳过片头播放
7.新增屏幕截图，支持mp4\m3u8等主流格式
8.新增试看

#### Add 1.0.10
1.新增midi内核 KJMIDIPlayer
2.完善KJPlayer

#### Add 1.0.9
1.重新整理，移除不再使用数据
2.重写播放器内核 KJAVPlayer

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
