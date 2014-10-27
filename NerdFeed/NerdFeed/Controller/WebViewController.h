//
//  WebViewController.h
//  NerdFeed
//
//  Created by zhaoqihao on 14-8-29.
//  Copyright (c) 2014年 com.zhaoqihao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ListViewController.h"

@interface WebViewController : UIViewController<UIWebViewDelegate,ListViewControllerDelegate,UISplitViewControllerDelegate>
{
    UIBarButtonItem *back;
    UIBarButtonItem *forward;
}

@property (nonatomic,readonly)UIWebView *webView;
@property (nonatomic,weak)ListViewController *listViewController;

@end
