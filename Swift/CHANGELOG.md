
### author information
### [Github](https://github.com/yangKJ)

> Remarks: Open the browser command quickly, command + shift + left mouse button

### Version update log
```
####Version update log:
#### Add 2.2.0
1. Change to swift project
2. Remove ijk
3. Remove the `PingTimer` and `DynamicSource`

#### Add 2.1.11
1. Add the function of closing the trial look `closeTryLook`
2. Add swift test cases

#### Add 2.1.10
1. Fix the problem that font resources are displayed as question marks
2. Re-modify the class name and add a time union

#### Add 2.1.9
1. Disassemble the download section, pod'KJPlayer/Downloader'
2. Standardize naming, delete obsolete method codes, etc.

#### Add 2.1.8
1. Disassemble the log class `KJPlayerLog`
2. Decoupling constant method classification and sorting `KJPlayerConstant`
3. `KJPlayerBridge` adds switch bridge method and receiving kernel method
4. Dynamically judge the side-by-side broadcast and verify the local cache

#### Add 2.1.7
1. Fix IJKPlayer error problem
2. Extract and improve the video cache

#### Add 2.1.6
1. Added background playback monitoring module, pod 'KJPlayer/BackgroundMonitoring'

#### Add 2.1.5
1. Withdraw the project function, increase the bridge file `KJPlayerBridge`
2. Cache section, pod 'KJPlayer/Cache'
3. Try to watch the video section, pod 'KJPlayer/TryTime'
4. Skip the opening and ending sections, pod 'KJPlayer/SKipTime'
5. Record viewing time section, pod 'KJPlayer/RecordTime'
6. Heartbeat package section, pod 'KJPlayer/PingTimer'
7. Video screenshot section, pod 'KJPlayer/Screenshots'
8. Dynamically switch the kernel section, pod 'KJPlayer/DynamicSource'
9. Database storage, pod 'KJPlayer/Database'
10. The default control panel, pod 'KJPlayer/CustomView'

#### Add 2.1.4
1. Refactor the code and add unit tests
2. Add testing tools

#### Add 2.1.3
1. Continue to improve the IJKPlyer kernel and fix problems
2. Separate the AVPlayer kernel while playing and saving branches, please use pod'KJPlayer/AVDownloader'
3. Organize and delete duplicate and useless code, optimize the logic processing
4. Asynchronous sub-threads get the last playing time and optimize performance

#### Add 2.1.2
1. Added KJIJKPlayer kernel to improve the basic streaming function
2. Separate the delegation agreement to KJPlayerProtocol
3. Fix the problem of failure to intercept HLS images in the KJAVPlayer kernel
4. Initially complete the dynamic switching kernel operation, kj_changeSourcePlayer:

#### Add 2.1.1
1. Optimize AVPlayer core file type
2. Fix the problem of coordinate misalignment of full-screen controls
3. Added the top and bottom operation panel, automatic hiding and gesture hiding operation functions
4. Optimize full screen/half screen

#### Add 2.1.0
1. Added KJRotateManager full screen/half screen management
2. New font icon usage
3. Improve the previous logical processing

#### Add 2.0.2
1. KJBasePlayerView added gesture management single click/double tap/long press
2. Handling fast-forward gestures, volume gestures, and brightness gestures
3. Fix the crash issue when the carrier center changes
4. Added progress and volume/brightness Layer controls
5. Fix the problem that the loading indicator/text prompt box disappears after switching sources
6. Separate loading animation and text prompt box

#### Add 2.0.1
1. Separate cache playback KJAVPlayer+KJCache
2. Modify and rewrite the network request section to realize the function of resuming the resuming of the breakpoint
3. Newly added player control base class KJBasePlayerView
4. The database adds the last play time, cache completion or not and other fields
5. Added circle animation loading, support for rich text prompt box
6. Added record playback and skip title playback
7. Added screenshots, supporting mainstream formats such as mp4\m3u8
8. New trial

#### Add 1.0.10
1. Added midi kernel KJMIDIPlayer
2. Perfect KJPlayer

#### Add 1.0.9
1. Reorganize and remove data that is no longer used
2. Rewrite the player kernel KJAVPlayer

#### Add 1.0.8
1. Introduce the header file KJPlayerHeader
2. Fix the playback from the beginning after switching the video definition
3. Expand the button click area KJPlayerButtonTouchAreaInsets

#### Add 1.0.6
1. Refactor KJDefinitionView definition panel
2. The configuration information class KJPlayerViewConfiguration adds a new attribute continuePlayWhenAppReception to control whether the background returns to play
3. The tool class KJPlayerTool adds kj_playerValidateUrl to determine whether the current URL is available

#### Add 1.0.5
1. Re-update KJPlayer playback mode
2. New definition selection

#### Add 1.0.4
1. Added KJFileOperation file operation class
2. KJPlayerView re-layout to add controls
3. Fix the bug that can not play long video

#### Add 1.0.3
1. Increase the play type function: repeat play, random play, sequence play, play only once
2. Optimize to improve player stability and reduce performance consumption
3. Added KJPlayerViewConfiguration class to manage and set default properties
4. Improve the full-screen layout, improve the KJFastView fast forward and reverse display area
5. Complete the gesture to fast forward and rewind, change the volume with the gesture, and change the screen direction after the gravity sensor is completed

#### Add 1.0.2
1. Improve the KJPlayerView display interface
2. Modify the bug

#### Add 1.0.0
1. Submit the project for the first time
2. Improve the KJPlayer function area
```
