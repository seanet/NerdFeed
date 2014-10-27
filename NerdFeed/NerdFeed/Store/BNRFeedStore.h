//
//  BNRFeedStore.h
//  NerdFeed
//
//  Created by zhaoqihao on 14-9-1.
//  Copyright (c) 2014年 com.zhaoqihao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "UpdateProgressDelegate.h"

@class RSSChannel;
@class RSSItem;

@interface BNRFeedStore : NSObject
{
    NSManagedObjectContext *context;
    NSManagedObjectModel *model;
}

@property (nonatomic,strong)NSDate *topSongsCacheDate;

+(BNRFeedStore *)sharedStore;

-(RSSChannel *)fetchRSSFeedWithCompletion:(void (^)(RSSChannel *obj,NSError *err))block caller:(id<UpdateProgressDelegate>)viewController;

-(void)fetchTopSongs:(int)count withCompletion:(void (^)(RSSChannel *obj,NSError *err))block caller:(id<UpdateProgressDelegate>)viewController;

-(void)markItemAsRead:(RSSItem *)item;
-(BOOL)hasItemBeenRead:(RSSItem *)item;

@end
