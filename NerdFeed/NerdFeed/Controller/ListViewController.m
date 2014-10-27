//
//  ListViewController.m
//  NerdFeed
//
//  Created by zhaoqihao on 14-8-29.
//  Copyright (c) 2014年 com.zhaoqihao. All rights reserved.
//

#import "ListViewController.h"
#import "RSSChannel.h"
#import "RSSItem.h"
#import "WebViewController.h"
#import "ChannelViewController.h"
#import "BNRFeedStore.h"
#import "PercentView.h"

@implementation ListViewController
@synthesize webViewController=_webViewController,channelViewcontroller=_channelViewcontroller;
@synthesize showListButton=_showListButton;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {        
        UIBarButtonItem *infoButton=[[UIBarButtonItem alloc]initWithTitle:@"Info" style:UIBarButtonItemStyleBordered target:self action:@selector(showInfo:)];
        [self.navigationItem setRightBarButtonItem:infoButton];
        
        UISegmentedControl *rssTypeControl=[[UISegmentedControl alloc]initWithItems:[NSArray arrayWithObjects:@"BNR",@"Apple", nil]];
        [rssTypeControl setSelectedSegmentIndex:0];
        [rssTypeControl addTarget:self action:@selector(changedType:) forControlEvents:UIControlEventValueChanged];
        [self.navigationItem setTitleView:rssTypeControl];
        
        [self fetchEntries];        
    }
    return self;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    NSLog(@"awake from nib");
}

-(void)fetchEntries
{
    [percentView setPercent:0];
    UIView *currentView=[self.navigationItem titleView];
    if(!aiView){
        aiView=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
        percentView=[[PercentView alloc]init];
        CGRect percentViewRect=percentView.frame;
        percentViewRect.origin.x=(aiView.bounds.size.width-percentViewRect.size.width)/2.0;
        percentViewRect.origin.y=(self.view.bounds.size.height-percentViewRect.size.height)/2.0-15;
        [percentView setFrame:percentViewRect];
        
        [aiView addSubview:percentView];
    }
    
    [self.navigationItem setTitleView:aiView];
    [aiView startAnimating];
    
    void(^completionBlock)(RSSChannel *obj,NSError *err)=^(RSSChannel *obj,NSError *err){
        [self.navigationItem setTitleView:currentView];
        
        if(!err){
            channel=obj;
            [self.tableView reloadData];
        }else{
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:[err localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    };
    
    if(rssType==ListViewControllerRSSTypeApple){
        [[BNRFeedStore sharedStore]fetchTopSongs:20 withCompletion:completionBlock caller:self];
    }else if(rssType==ListViewControllerRSSTypeBNR){
        channel= [[BNRFeedStore sharedStore]fetchRSSFeedWithCompletion:^(RSSChannel *obj,NSError *err){
            [self.navigationItem setTitleView:currentView];
            
            if(!err){
                NSUInteger currentItemsCount=[channel.items count];
                channel=obj;
                NSUInteger newItemsCount=[channel.items count];
                
                NSInteger itemDelta=newItemsCount-currentItemsCount;
                if(itemDelta>0){
                    NSMutableArray *rows=[NSMutableArray array];
                    for(int i=0;i<itemDelta;i++){
                        NSIndexPath *ip=[NSIndexPath indexPathForRow:i inSection:0];
                        [rows addObject:ip];
                    }
                    [self.tableView insertRowsAtIndexPaths:rows withRowAnimation:UITableViewRowAnimationTop];
                }
            }
        } caller:self];
        [self.tableView reloadData];
    }
}

-(void)showInfo:(id)sender
{
    if(!_channelViewcontroller){
        _channelViewcontroller=[[ChannelViewController alloc]initWithStyle:UITableViewStyleGrouped];
        [_channelViewcontroller setListViewController:self];
    }
    
    if(_showListButton){
        [_channelViewcontroller.navigationItem setLeftBarButtonItem:_showListButton];
    }else{
        [_channelViewcontroller.navigationItem setLeftBarButtonItem:nil];
    }

    if([self splitViewController]){
        UINavigationController *channelNav=[[UINavigationController alloc]initWithRootViewController:_channelViewcontroller];
        NSArray *array=[NSArray arrayWithObjects:self.navigationController,channelNav, nil];
        
        [self.splitViewController setViewControllers:array];
        [self.splitViewController setDelegate:_channelViewcontroller];
        
        NSIndexPath *selectedRow=[self.tableView indexPathForSelectedRow];
        if(selectedRow){
            [self.tableView deselectRowAtIndexPath:selectedRow animated:YES];
        }
        
    }else{
        [self.navigationController pushViewController:_channelViewcontroller animated:YES];
    }
    
    [_channelViewcontroller listViewController:self handleObject:channel];
}

-(void)changedType:(id)sender
{
    rssType=(ListViewControllerRSSType)[sender selectedSegmentIndex];
    [self fetchEntries];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[channel items]count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if(!cell){
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    }
    
    RSSItem *item=[[channel items]objectAtIndex:[indexPath row]];
    [cell.textLabel setText:item.title];
    
    if([[BNRFeedStore sharedStore]hasItemBeenRead:item]){
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }else{
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RSSItem *item=[[channel items]objectAtIndex:[indexPath row]];
    [_webViewController listViewController:self handleObject:item];
    
    [[BNRFeedStore sharedStore]markItemAsRead:item];
    [[self.tableView cellForRowAtIndexPath:indexPath]setAccessoryType:UITableViewCellAccessoryCheckmark];
    
    if([self splitViewController]){
        UINavigationController *nav=[[UINavigationController alloc]initWithRootViewController:_webViewController];
        NSArray *array=[NSArray arrayWithObjects:self.navigationController,nav, nil];
        [self.splitViewController setViewControllers:array];
        
        [self.splitViewController setDelegate:_webViewController];
        
        if(_showListButton){
            [_webViewController.navigationItem setLeftBarButtonItem:_showListButton];
        }else{
            [_webViewController.navigationItem setLeftBarButtonItem:nil];
        }
    }else{
        [self.navigationController pushViewController:_webViewController animated:YES];
    }
}

#pragma mark - updateprogress delegate

-(void)updateProgress:(double)progress
{
    NSInteger progressInt=floor(progress*100);
    [percentView setPercent:progressInt];
}

@end
