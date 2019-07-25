//
//  KJPlayerViewHeader.h
//  KJPlayerDemo
//
//  Created by 杨科军 on 2019/7/22.
//  Copyright © 2019 杨科军. All rights reserved.
//

#ifndef KJPlayerViewHeader_h
#define KJPlayerViewHeader_h

/// text size(文字尺寸)
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
#define PLAYER_MULTILINE_TEXTSIZE(text, font, maxSize, mode) [text length] > 0 ? [text \
boundingRectWithSize:maxSize options:(NSStringDrawingUsesLineFragmentOrigin) \
attributes:@{NSFontAttributeName:font} context:nil].size : CGSizeZero;
#else
#define PLAYER_MULTILINE_TEXTSIZE(text, font, maxSize, mode) [text length] > 0 ? [text \
sizeWithFont:font constrainedToSize:maxSize lineBreakMode:mode] : CGSizeZero;
#endif

// 屏幕尺寸
#define PLAYER_SCREEN_WIDTH  ([UIScreen mainScreen].bounds.size.width)
#define PLAYER_SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
/// 颜色
#define PLAYER_UIColorFromHEXA(hex,a) [UIColor colorWithRed:((hex&0xFF0000)>>16)/255.0f green:((hex&0xFF00)>>8)/255.0f blue:(hex&0xFF)/255.0f alpha:a]
/** 设置图片 */
#define PLAYER_GET_BUNDLE_IMAGE(imageName) ([UIImage imageNamed:[@"KJPlayerView.bundle" stringByAppendingPathComponent:(imageName)]])
/// 字体
#define PLAYER_SystemFontSize(fontsize)     [UIFont systemFontOfSize:(fontsize)]
#define PLAYER_SystemBlodFontSize(fontsize) [UIFont boldSystemFontOfSize:(fontsize)] /// 粗体

#import "KJPlayerTool.h"

#endif /* KJPlayerViewHeader_h */
