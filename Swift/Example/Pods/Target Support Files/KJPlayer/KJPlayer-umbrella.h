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

#import "KJDownloader.h"
#import "KJDownloaderCommon.h"
#import "KJFileHandleInfo.h"
#import "KJFileHandleManager.h"
#import "KJPlayer-Bridging-Header.h"

FOUNDATION_EXPORT double KJPlayerVersionNumber;
FOUNDATION_EXPORT const unsigned char KJPlayerVersionString[];

