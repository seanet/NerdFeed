//
//  BNRFeedStore.m
//  NerdFeed
//
//  Created by zhaoqihao on 14-9-1.
//  Copyright (c) 2014年 com.zhaoqihao. All rights reserved.
//

#import "BNRFeedStore.h"
#import "RSSChannel.h"
#import "BNRConnection.h"
#import "RSSItem.h"

@implementation BNRFeedStore
@synthesize topSongsCacheDate=_topSongsCacheDate;

+(BNRFeedStore *)sharedStore
{
    static BNRFeedStore *sharedStore=nil;
    if(!sharedStore){
        sharedStore =[[super allocWithZone:nil]init];
    }
    
    return sharedStore;
}

+(id)allocWithZone:(struct _NSZone *)zone
{
    return [self sharedStore];
}

-(id)init
{
    self=[super init];
    if(self){
        model=[NSManagedObjectModel mergedModelFromBundles:nil];
        NSPersistentStoreCoordinator *psc=[[NSPersistentStoreCoordinator alloc]initWithManagedObjectModel:model];
        NSError *err=nil;
        NSString *dbPath=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        dbPath =[dbPath stringByAppendingPathComponent:@"feed.db"];
        
        if(![psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[NSURL fileURLWithPath:dbPath] options:nil error:&err]){
            [NSException raise:@"Open faided" format:@"Reason:%@",[err localizedDescription]];
        }
        
        context=[[NSManagedObjectContext alloc]init];
        [context setPersistentStoreCoordinator:psc];
        [context setUndoManager:nil];
    }
    
    return self;
}

-(void)setTopSongsCacheDate:(NSDate *)topSongsCacheDate
{
    [[NSUserDefaults standardUserDefaults]setObject:topSongsCacheDate forKey:@"topSongsCacheDate"];
}

-(NSDate *)topSongsCacheDate
{
    return [[NSUserDefaults standardUserDefaults]objectForKey:@"topSongsCacheDate"];
}

-(RSSChannel *)fetchRSSFeedWithCompletion:(void (^)(RSSChannel *, NSError *))block caller:(id<UpdateProgressDelegate>)viewController
{
    NSString *urlStr=@"http://forums.bignerdranch.com/smartfeed.php?" @"limit=1_DAY&sort_by=standard&feed_type=RSS2.0&feed_style=COMPACT";
    NSURL *url=[NSURL URLWithString:urlStr];
    NSURLRequest *request=[NSURLRequest requestWithURL:url];
    
    RSSChannel *channel=[[RSSChannel alloc]init];
    
    BNRConnection *connection=[[BNRConnection alloc]initWithRequest:request];

    NSString *cachePath=[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    cachePath=[cachePath stringByAppendingPathComponent:@"nerd.archive"];
    RSSChannel *cacheChannel=[NSKeyedUnarchiver unarchiveObjectWithFile:cachePath];
    if(!cacheChannel){
        cacheChannel=[[RSSChannel alloc]init];
    }
    
    RSSChannel *copyChannel=[cacheChannel copy];
    
    [connection setCompletionBlock:^(RSSChannel *obj,NSError *err){
        if(!err){
            [copyChannel addItemsFromChannel:obj];
            [NSKeyedArchiver archiveRootObject:copyChannel toFile:cachePath];
        }
        
        block(copyChannel,err);
    }];
    
    [connection setXmlRootObject:channel];
    [connection setBackgroundSessionID:@"BNRBackgroundSessionID"];
    if(viewController){
        [connection setDelegate:viewController];
    }
    
    [connection start];
    return cacheChannel;
}

-(void)fetchTopSongs:(int)count withCompletion:(void (^)(RSSChannel *, NSError *))block caller:(id<UpdateProgressDelegate>)viewController
{
    NSString *cachePath=[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    cachePath =[cachePath stringByAppendingPathComponent:@"apple.archive"];
    
    if(self.topSongsCacheDate){
        NSTimeInterval cacheAge=[self.topSongsCacheDate timeIntervalSinceNow];
        if(cacheAge > -300){
            NSLog(@"Reading cache!");
            
            RSSChannel *cachedChannel=[NSKeyedUnarchiver unarchiveObjectWithFile:cachePath];
            if(cachedChannel){
                [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                    block(cachedChannel,nil);
                }];                
                return;
            }
        }
    }
    
    NSString *urlStr=[NSString stringWithFormat:@"http://itunes.apple.com/us/rss/topsongs/limit=%d/json",count];
    NSURL *url=[NSURL URLWithString:urlStr];
    NSURLRequest *req=[NSURLRequest requestWithURL:url];
    
    RSSChannel *channel=[[RSSChannel alloc]init];
    
    BNRConnection *connection=[[BNRConnection alloc]initWithRequest:req];
    
    [connection setCompletionBlock:^(RSSChannel *obj,NSError *err){
        if(!err){
            self.topSongsCacheDate=[NSDate date];
            [NSKeyedArchiver archiveRootObject:obj toFile:cachePath];
        }
        
        block(obj,err);
    }];
    
    [connection setJsonRootObject:channel];
    [connection setBackgroundSessionID:@"AppleBackgroundSessionID"];
    if(viewController){
        [connection setDelegate:viewController];
    }
    
    [connection start];
}

-(void)markItemAsRead:(RSSItem *)item
{
    if([self hasItemBeenRead:item]){
        return;
    }
    
    NSManagedObject *obj=[NSEntityDescription insertNewObjectForEntityForName:@"Link" inManagedObjectContext:context];
    [obj setValue:[item link] forKey:@"urlString"];
    [context save:nil];
}

-(BOOL)hasItemBeenRead:(RSSItem *)item
{
    NSFetchRequest *request=[[NSFetchRequest alloc]initWithEntityName:@"Link"];
    NSPredicate *pred=[NSPredicate predicateWithFormat:@"urlString like %@",item.link];
    [request setPredicate:pred];
    
    NSArray *results=[context executeFetchRequest:request error:nil];
    if([results count]>0){
        return YES;
    }
    
    return NO;
}

@end
