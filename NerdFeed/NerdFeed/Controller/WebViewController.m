//
//  WebViewController.m
//  NerdFeed
//
//  Created by zhaoqihao on 14-8-29.
//  Copyright (c) 2014年 com.zhaoqihao. All rights reserved.
//

#import "WebViewController.h"
#import "RSSItem.h"

@implementation WebViewController
@synthesize webView=_webView;
@synthesize listViewController=_listViewController;

-(void)loadView
{
    UIWebView *wv=[[UIWebView alloc]init];
    [wv setScalesPageToFit:YES];
    [wv setDelegate:self];
    [self setView:wv];
    
    back=[[UIBarButtonItem alloc]initWithTitle:@"back" style:UIBarButtonItemStyleBordered target:self action:@selector(goBack:)];
    forward=[[UIBarButtonItem alloc]initWithTitle:@"forward" style:UIBarButtonItemStylePlain target:self action:@selector(goForward:)];
    [self setButtonState];
    self.navigationItem.rightBarButtonItems=[NSArray arrayWithObjects:forward,back, nil];
}

-(void)viewDidLoad
{
    self.view.backgroundColor=[UIColor whiteColor];
}

-(UIWebView *)webView
{
    return (UIWebView *)self.view;
}

-(void)goBack:(id)sender
{
    [self.webView goBack];
}

-(void)goForward:(id)sender
{
    [self.webView goForward];
}

-(void)setButtonState
{
    if([self.webView canGoBack]){
        back.enabled=YES;
    }else{
        back.enabled=NO;
    }
    
    if([self.webView canGoForward]){
        forward.enabled=YES;
    }else{
        forward.enabled=NO;
    }
}

#pragma mark - webview delegate

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self setButtonState];
}

#pragma mark - listviewcontroller delegate

-(void)listViewController:(ListViewController *)lvc handleObject:(id)object
{
    RSSItem *item=object;
    
    if(![item isKindOfClass:[RSSItem class]]){
        return;
    }
    
    NSURL *url=[NSURL URLWithString:[item link]];
    NSURLRequest *request=[NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
    
    [self.navigationItem setTitle:item.title];
}

#pragma mark - uisplitviewcontroller delegate

-(void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc
{
    [barButtonItem setTitle:@"ShowList"];
    [self.navigationItem setLeftBarButtonItem:barButtonItem];
    [_listViewController setShowListButton:barButtonItem];
}

-(void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    if(barButtonItem==[self.navigationItem leftBarButtonItem]){
        [self.navigationItem setLeftBarButtonItem:nil];
        [_listViewController setShowListButton:nil];
    }
}

@end
