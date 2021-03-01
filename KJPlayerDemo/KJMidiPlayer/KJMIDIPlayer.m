//
//  KJMIDIPlayer.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/2.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJMIDIPlayer.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"

@interface KJMIDIPlayer()
PLAYER_COMMON_EXTENSION_PROPERTY
@property (nonatomic,assign) MusicPlayer player;

@end
@implementation KJMIDIPlayer{
    AUGraph graph;/// 音频处理图
    AUNode sourceNode;/// 输入节点
    AUNode destNode;/// 输出节点
    AudioUnit remoteIOUnit;/// 属性值的音频单元
    MusicSequence sequence;/// 音乐序列
}
PLAYER_COMMON_FUNCTION_PROPERTY PLAYER_COMMON_UI_PROPERTY
- (instancetype)init{
    if (self = [super init]) {
        _speed = 1.;
        _timeSpace = 1.;
        _autoPlay = YES;
        _videoGravity = KJPlayerVideoGravityResizeAspect;
        _background = UIColor.blackColor.CGColor;
        self.group = dispatch_group_create();
    }
    return self;
}
- (void)dealloc{
    [self kj_stop];
}

#pragma mark - public method
/* 准备播放 */
- (void)kj_play{
    PLAYER_WEAKSELF;
    dispatch_group_notify(self.group, dispatch_get_main_queue(), ^{
        if (weakself.player == nil || weakself.tryLooked) return;
        MusicPlayerStart(weakself.player);
        weakself.userPause = NO;
    });
}
/* 重播 */
- (void)kj_replay{
    [self kj_play];
}
/* 继续 */
- (void)kj_resume{
    if (self.player == nil) return;
    self.state = KJPlayerStatePausing;
    self.userPause = YES;
    if (![self isPlaying] && self.player) MusicPlayerStart(self.player);
    [self startGraph];
}
/* 暂停 */
- (void)kj_pause{
    if (self.player == nil) return;
    self.state = KJPlayerStatePausing;
    self.userPause = YES;
    if ([self isPlaying]) MusicPlayerStop(self.player);
    [self stopGraph];
}
/* 停止 */
- (void)kj_stop{
    [self stopGraph];
    if (self.player) {
        MusicPlayerStop(self.player);
        DisposeMusicPlayer(self.player);
        self.player = nil;
    }
    if (sequence) DisposeMusicSequence(sequence);
    if (graph) DisposeAUGraph(graph);
    self.state = KJPlayerStateStopped;
}
/* 圆圈加载动画 */
- (void)kj_startAnimation{
    [super kj_startAnimation];
}
/* 停止动画 */
- (void)kj_stopAnimation{
    [super kj_stopAnimation];
}

#pragma mark - setter
- (void)setOriginalURL:(NSURL *)originalURL{
    _originalURL = originalURL;
    kGCD_player_main(^{
        self.state = KJPlayerStateBuffering;
    });
}
- (void)setVideoURL:(NSURL *)videoURL{
    self.originalURL = videoURL;
    self.cache = NO;
    if (kPlayerVideoAesstType(videoURL) == KJPlayerAssetTypeNONE) {
        _videoURL = videoURL;
        self.playError = [DBPlayerDataInfo kj_errorSummarizing:KJPlayerCustomCodeVideoURLUnknownFormat];
        if (self.player) [self kj_stop];
        return;
    }
    PLAYER_WEAKSELF;
    __block NSURL *tempURL = videoURL;
    dispatch_group_async(self.group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (![tempURL.absoluteString isEqualToString:self->_videoURL.absoluteString]) {
            self->_videoURL = tempURL;
            [weakself createGraph];
            [weakself loadAudioUnitSetProperty];
            [weakself loadMusicSequenceFileWithURL:tempURL];
        }else{
            [weakself kj_replay];
        }
    });
}
- (void)setVolume:(float)volume{
    _volume = MIN(MAX(0, volume), 1);
//    if (self.player) self.player.volume = volume;
}
- (void)setMuted:(BOOL)muted{
    if (self.player && _muted != muted) {
//        self.player.muted = muted;
    }
    _muted = muted;
}
- (void)setSpeed:(float)speed{
    if (self.player && _speed != speed) {
        if (speed <= 0) {
            speed = 0.1;
        }else if (speed >= 2){
            speed = 2;
        }
        MusicPlayerSetPlayRateScalar(self.player,speed);
    }
    _speed = speed;
}
- (void)setBackground:(CGColorRef)background{
//    if (_playerLayer && _background != background) {
//        _playerLayer.backgroundColor = background;
//    }
    _background = background;
}
- (void)setTimeSpace:(NSTimeInterval)timeSpace{
    if (_timeSpace != timeSpace) {
        _timeSpace = timeSpace;
//        [self kj_addTimeObserver];
    }
}
- (void)setPlayerView:(KJBasePlayerView *)playerView{
    if (playerView == nil) return;
    _playerView = playerView;
//    self.playerLayer.frame = playerView.bounds;
//    if (self.playerLayer.superlayer == nil) {
//        [playerView.layer addSublayer:self.playerLayer];
//    }
}

#pragma mark - getter
- (BOOL)isPlaying{
    if (self.player == nil) return NO;
    Boolean xxxxx = NO;
    MusicPlayerIsPlaying(self.player, &xxxxx);
    return xxxxx;
}
/* 快进或快退 */
- (void (^)(NSTimeInterval,void (^_Nullable)(BOOL)))kVideoAdvanceAndReverse{
    return ^(NSTimeInterval seconds,void (^xxblock)(BOOL)){
       PLAYER_WEAKSELF;
        __block  MusicTimeStamp time = seconds;
        dispatch_group_notify(self.group, dispatch_get_main_queue(), ^{
            if (weakself.totalTime) {
                weakself.currentTime = time;
            }
            SInt32 xx = MusicPlayerSetTime(weakself.player, time);
            if (xx >= 0) [weakself kj_play];
            if (xxblock) xxblock(xx>=0);
        });
    };
}
- (void (^)(void (^ _Nullable)(void), NSTimeInterval))kVideoTryLookTime{
    return ^(void (^xxblock)(void), NSTimeInterval time){
        self.tryTime = time;
        self.tryTimeBlock = xxblock;
    };
}
- (void (^)(void (^ _Nonnull)(NSTimeInterval), BOOL))kVideoRecordLastTime{
    return ^(void(^xxblock)(NSTimeInterval), BOOL record){
        self.recordLastTime = record;
        self.recordTimeBlock = xxblock;
    };
}
- (void (^)(void (^ _Nonnull)(KJPlayerVideoSkipState), NSTimeInterval, NSTimeInterval))kVideoSkipTime{
    return ^(void(^xxblock)(KJPlayerVideoSkipState), NSTimeInterval headTime, NSTimeInterval footTime){
        self.skipHeadTime = headTime;
        self.skipTimeBlock = xxblock;
    };
}

#pragma mark - private method
- (void)createGraph {
    if (self.player) [self kj_stop];
    NewAUGraph(&graph);

    AudioComponentDescription sourceNodeDes;
    sourceNodeDes.componentType = kAudioUnitType_MusicDevice;
    sourceNodeDes.componentSubType = kAudioUnitSubType_Sampler;
    sourceNodeDes.componentManufacturer = kAudioUnitManufacturer_Apple;
    AUGraphAddNode(graph, &sourceNodeDes, &sourceNode);
    
    AudioComponentDescription destNodeDes;
    destNodeDes.componentType = kAudioUnitType_Output;
    destNodeDes.componentSubType = kAudioUnitSubType_RemoteIO;
    destNodeDes.componentManufacturer = kAudioUnitManufacturer_Apple;
    AUGraphAddNode(graph, &destNodeDes, &destNode);
    
    AUGraphOpen(graph);
    AUGraphNodeInfo(graph, sourceNode, NULL, &remoteIOUnit);
    AUGraphConnectNodeInput(graph, sourceNode, 0, destNode, 0);
    AUGraphInitialize(graph);
    
    [self startGraph];
}

- (void)loadAudioUnitSetProperty{
    NSURL *bankURL = [[NSBundle mainBundle] URLForResource:@"KJMidiSource.bundle/instrument" withExtension:@"dls"];
    AUSamplerInstrumentData data;
    data.fileURL        = (__bridge CFURLRef)bankURL;
    data.instrumentType = kInstrumentType_DLSPreset;
    data.bankMSB        = kAUSampler_DefaultMelodicBankMSB;
    data.bankLSB        = kAUSampler_DefaultBankLSB;
    data.presetID       = 0;
    AudioUnitSetProperty(remoteIOUnit, kAUSamplerProperty_LoadInstrument, kAudioUnitScope_Global, 0, &data, sizeof(data));
}

- (void)loadMusicSequenceFileWithURL:(NSURL*)fileURL{
    NewMusicSequence(&sequence);
    MusicSequenceFileLoad(sequence,
                          (__bridge CFURLRef)fileURL,
                          kMusicSequenceFile_MIDIType,
                          kMusicSequenceLoadSMF_ChannelsToTracks);
    MusicSequenceSetAUGraph(sequence, graph);
    
    NewMusicPlayer(&_player);
    MusicPlayerSetSequence(self.player, sequence);
    MusicPlayerPreroll(self.player);
}
/// 开启音频处理图
- (void)startGraph{
    if (graph && ![self isPlaying]) AUGraphStart(graph);
}
/// 停止音频处理图
- (void)stopGraph{
    if (graph && [self isPlaying]) AUGraphStop(graph);
}

@end
#pragma clang diagnostic pop
