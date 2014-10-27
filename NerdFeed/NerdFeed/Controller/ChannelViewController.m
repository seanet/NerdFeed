//
//  ChannelViewController.m
//  NerdFeed
//
//  Created by zhaoqihao on 14-8-30.
//  Copyright (c) 2014年 com.zhaoqihao. All rights reserved.
//

#import "ChannelViewController.h"
#import "RSSChannel.h"

@implementation ChannelViewController
@synthesize listViewController=_listViewController;

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if(!cell){
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"UITableViewCell"];
    }
    
    if([indexPath row]==0){
        [cell.textLabel setText:@"Title"];
        if(channel.title){
            [cell.detailTextLabel setText:channel.title];
        }else{
            [cell.detailTextLabel setText:@""];
        }
        
    }else{
        [cell.textLabel setText:@"Info"];
        if(channel.infoString){
            [cell.detailTextLabel setText:channel.infoString];
        }else{
            [cell.detailTextLabel setText:@""];
        }
    }
    
    return cell;
}

#pragma mark - listviewcontroller delegate

-(void)listViewController:(ListViewController *)lvc handleObject:(id)object
{
    if(![object isKindOfClass:[RSSChannel class]]){
        return;
    }
    
    channel=object;
    [self.tableView reloadData];
}

#pragma mark - uisplitviewcontroller delegate

-(void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc
{
    [barButtonItem setTitle:@"showList"];
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
