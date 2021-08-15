#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "KJPlayerHeader.h"
#import "KJAVPlayer.h"
#import "KJDownloader.h"
#import "KJFileHandleInfo.h"
#import "KJFileHandleManager.h"
#import "KJAVPlayer+KJCache.h"
#import "KJResourceLoader.h"
#import "KJResourceLoaderManager.h"
#import "DBPlayerData.h"
#import "DBPlayerDataManager.h"
#import "KJBaseFunctionPlayer.h"
#import "KJBasePlayer+KJPingTimer.h"
#import "KJBasePlayer+KJRecordTime.h"
#import "KJBasePlayer.h"
#import "KJCacheManager.h"
#import "KJCustomManager.h"
#import "KJPlayerProtocol.h"
#import "KJPlayerType.h"
#import "KJPlayerView.h"
#import "KJBasePlayerView.h"
#import "KJPlayerButton.h"
#import "KJPlayerFastLayer.h"
#import "KJPlayerHintLayer.h"
#import "KJPlayerLoadingLayer.h"
#import "KJPlayerOperationView.h"
#import "KJPlayerSystemLayer.h"
#import "KJRotateManager.h"
#import "KJIJKPlayer.h"
#import "KJMIDIPlayer.h"

FOUNDATION_EXPORT double KJPlayerVersionNumber;
FOUNDATION_EXPORT const unsigned char KJPlayerVersionString[];

