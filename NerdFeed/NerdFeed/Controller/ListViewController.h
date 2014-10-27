//
//  ListViewController.h
//  NerdFeed
//
//  Created by zhaoqihao on 14-8-29.
//  Copyright (c) 2014年 com.zhaoqihao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UpdateProgressDelegate.h"

@class RSSChannel,WebViewController,ChannelViewController;
@class PercentView;

typedef enum{
    ListViewControllerRSSTypeBNR,
    ListViewControllerRSSTypeApple
}ListViewControllerRSSType;

@interface ListViewController : UITableViewController<UpdateProgressDelegate>
{    
    RSSChannel *channel;
    ListViewControllerRSSType rssType;
    
    PercentView *percentView;
    UIActivityIndicatorView *aiView;
}

@property (nonatomic,strong)WebViewController *webViewController;
@property (nonatomic,strong)ChannelViewController *channelViewcontroller;
@property (nonatomic,weak)UIBarButtonItem *showListButton;

-(void)fetchEntries;

@end


@protocol ListViewControllerDelegate <NSObject>

-(void)listViewController:(ListViewController *)lvc handleObject:(id)object;

@end