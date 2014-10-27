//
//  NerdFeedAppDelegate.h
//  NerdFeed
//
//  Created by zhaoqihao on 14-8-29.
//  Copyright (c) 2014年 com.zhaoqihao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface NerdFeedAppDelegate : UIResponder <UIApplicationDelegate,AVAudioPlayerDelegate>
{
    AVAudioPlayer *player;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong,nonatomic) void(^backgroundURLSessionCompletionHandler)();

@end
