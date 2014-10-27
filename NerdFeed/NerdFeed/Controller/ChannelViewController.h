//
//  ChannelViewController.h
//  NerdFeed
//
//  Created by zhaoqihao on 14-8-30.
//  Copyright (c) 2014年 com.zhaoqihao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ListViewController.h"

@interface ChannelViewController : UITableViewController<ListViewControllerDelegate,UISplitViewControllerDelegate>
{
    RSSChannel *channel;
}

@property (nonatomic,weak)ListViewController *listViewController;

@end
