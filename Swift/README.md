# KJPlayer

🎸- Good News, **audio and video player** has undergone a major revision 2.0

### <a id="Feature introduction"></a> Feature introduction
**Dynamic switching of the core, support for the player program of the side-to-play**

* Support audio/video playback, midi file playback
* Support online play and local play
* Support background playback, audio extraction and playback
* Support video side-by-side play, segmented download, play and store
* Support breakpoint resuming and resuming playback, next time it is directly read and played from the buffer
* Support cache management, clear time period cache
* Support free look limit, automatically skip the opening and ending credits
* Support recording the last playing time
* Support auto play, auto continuous play
* Support random/repeat/sequential playback
* Support gravity sensor, full screen/half screen switch
* Support basic gesture operation, progress volume, etc.
* Support lock screen
* Long press to fast forward and rewind and other operations
* Support double speed playback
* Support switching between different resolution videos
* Support live streaming media playback
* Continuously updating...

----------------------------------------
> Video support formats: mp4, m3u8, wav, avi, etc.  
> Audio support formats: midi, mp3, etc.

----------------------------------------

### <a id="Effect picture"></a>Effect picture
| <img src="Document/AAA.png" width="300" align="center" /> | <img src="Document/XXX.png" width="300" align="center" /> |
| --- | --- |

### Free look feature
- This function is similar to the viewing nature of Vip members, and the viewing mode will continue to be played after recharging

```
// MARK: - KJPlayerFreeDelegate
extension DetailsViewController: KJPlayerFreeDelegate {

    /// Get free look time
    /// - Parameter player: player core
    /// - Returns: try to see the time, return zero without limit
    func kj_freeLookTime(with player: KJBasePlayer) -> TimeInterval {
        return 50
    }
    
    /// Free viewing time has ended
    func kj_freeLookReached(with player: KJBasePlayer, currentTime: TimeInterval) {
        
    }
}
```
- Restore viewing rights after top-up

```
self.player.kj_closeFreeLookTimeLimit()
```

#### CocoaPods installation free look module
```
pod 'KJPlayer/FreeTime' # vip try to watch function
```

### Skip opening and ending credits function
- This function is clearly similar to skip the opening and ending credits when watching a video

```
// MARK: - KJPlayerSkipDelegate
extension DetailsViewController: KJPlayerSkipDelegate {
    
    /// Get the opening time of the beginning of the play
    func kj_skipHeadTime(with player: KJBasePlayer) -> TimeInterval {
        return 18
    }
    
    /// Skip opening begin play response
    func kj_skipIntro(with player: KJBasePlayer, openingTime: TimeInterval) {
        self.backview.hintTextLayer.kj_displayHintText("Skip head intro, automatically play",
                                                       time: 5,
                                                       position: KJPlayerHintPositionBottom)
    }
}
```

#### CocoaPods installation skip the opening and ending module
```
pod 'KJPlayer/SkipTime' # vip skip opening and ending credits function
```

### Record played time function
- This function will automatically record the last playing time and continue playing seamlessly next time

```
// MARK: - KJPlayerRecordDelegate
extension DetailsViewController: KJPlayerRecordDelegate {

    /// Get whether the response needs to be recorded
    func kj_recordTime(with player: KJBasePlayer) -> Bool {
        return true
    }
    
    /// Get the response to the last play time
    func kj_recordTime(with player: KJBasePlayer, lastTime: TimeInterval) {
        
    }
}

```
- Actively select storage memory

```
self.player.kj_saveRecordLastTime()
```

#### CocoaPods install automatic record played time module
```
pod 'KJPlayer/RecordTime' # vip automatic memory playback function
```

> Remarks: This function is greater than the skip title function. Simply put, after this function is implemented, it will continue to watch from the last playback position next time.

----------------------------------------

### Other functional modules
#### 1. Player module
- midi player: `pod 'KJPlayer/MIDI'`
- ijk player: `pod 'KJPlayer/IJKPlayer'`
- av player: `pod 'KJPlayer/AVPlayer/AVCore'`
- custom play view: `pod 'KJPlayer/CustomView'`

#### 2. Functional area module
- AVPlayer kernel extension function
    - Play and save the branch: `pod 'KJPlayer/AVPlayer/AVDownloader'`

- Record played time: `pod 'KJPlayer/RecordTime'`
- Free look: `pod 'KJPlayer/FreeTime'`
- Skip the opening and ending credits: `pod 'KJPlayer/SkipTime'`
- Cache section: `pod 'KJPlayer/Cache'`
- Video screenshot section: `pod 'KJPlayer/Screenshots'`
  
- Switch kernel player: `pod 'KJPlayer/DynamicSource`
  - Currently supports 3 kinds of cores: AVPlayer, MIDI, IJKPlayer

> The general process is almost like this, the Demo is also written in great detail, you can check it out for yourself.🎷

> [KJPlayerDemo](https://github.com/yangKJ/KJPlayerDemo)

> Tip: The general function is completed, then slowly add other kernels later, if you find it helpful, please help me with a star. If you have any questions or needs, you can also issue.

> Thanks.🎇

### About the author
- 🎷 **E-mail address: [ykj310@126.com](ykj310@126.com) 🎷**
- 🎸 **GitHub address: [yangKJ](https://github.com/yangKJ) 🎸**
- 🎺 **Nuggets address: [Under Tea World](https://juejin.cn/user/1987535102554472/posts) 🎺**
- 🚴🏻 **Short book address: [77___](https://www.jianshu.com/u/c84c00476ab6) 🚴🏻**

-----
