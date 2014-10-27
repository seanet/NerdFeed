//
//  NerdFeedAppDelegate.m
//  NerdFeed
//
//  Created by zhaoqihao on 14-8-29.
//  Copyright (c) 2014年 com.zhaoqihao. All rights reserved.
//

#import "NerdFeedAppDelegate.h"
#import "ListViewController.h"
#import "WebViewController.h"

@implementation NerdFeedAppDelegate
@synthesize backgroundURLSessionCompletionHandler=_backgroundURLSessionCompletionHandler;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];

    ListViewController *listViewController=[[ListViewController alloc]initWithStyle:UITableViewStylePlain];
    
    WebViewController *webViewController=[[WebViewController alloc]init];
    [webViewController setListViewController:listViewController];
    
    listViewController.webViewController=webViewController;
    
    UINavigationController *navigationController=[[UINavigationController alloc]initWithRootViewController:listViewController];
    
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPad){
        UINavigationController *detailNavigationController=[[UINavigationController alloc]initWithRootViewController:webViewController];
        NSArray *array=[NSArray arrayWithObjects:navigationController,detailNavigationController, nil];
        
        UISplitViewController *splitViewController=[[UISplitViewController alloc]init];
        [splitViewController setViewControllers:array];
        [splitViewController setDelegate:webViewController];
        
        [self.window setRootViewController:splitViewController];
    }else{
        [self.window setRootViewController:navigationController];
    }
    
    [[UIApplication sharedApplication]setApplicationIconBadgeNumber:4];
    
    [[UIApplication sharedApplication]setMinimumBackgroundFetchInterval:5];
    
    [self.window makeKeyAndVisible];
    
    [self playAudioBackground];
    
    return YES;
}

-(void)applicationDidEnterBackground:(UIApplication *)application
{
    NSLog(@"enter background");
    
//    __block UIBackgroundTaskIdentifier backgroundTask;
//    
//    void(^endBackgroundTask)()=^{
//        [application endBackgroundTask:backgroundTask];
//        backgroundTask=UIBackgroundTaskInvalid;
//    };
//    
//    backgroundTask=[application beginBackgroundTaskWithExpirationHandler:^{
//        endBackgroundTask();
//    }];
//    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        NSLog(@"%g",application.backgroundTimeRemaining);
//    });
    
}

//play audio background
-(void)playAudioBackground
{
    NSError *categoryError;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    if(categoryError){
        NSLog(@"set category error: %@",[categoryError description]);
    }
    
    NSError *activitionError;
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    if(activitionError){
        NSLog(@"set activition error: %@",[activitionError description]);
    }
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    NSString *musicPath=[[NSBundle mainBundle]pathForResource:@"19731" ofType:@"mp3"];
    if(musicPath){
        NSURL *musicURL=[[NSURL alloc]initFileURLWithPath:musicPath];
        NSError *playerError;
        player=[[AVAudioPlayer alloc]initWithContentsOfURL:musicURL error:&playerError];
        if(playerError){
            NSLog(@"create avaudio player error: %@",[playerError description]);
        }
        
        [player setDelegate:self];
        
        [player prepareToPlay];
        [player setVolume:-1];
        [player setNumberOfLoops:-1];
        
        [player play];
    }    
}

//background fetch
-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [[UIApplication sharedApplication]setApplicationIconBadgeNumber:5];
    
    NSString *urlStr=@"http://forums.bignerdranch.com/smartfeed.php?" @"limit=1_DAY&sort_by=standard&feed_type=RSS2.0&feed_style=COMPACT";
    NSURL *url=[NSURL URLWithString:urlStr];
    NSURLRequest *request=[NSURLRequest requestWithURL:url];
    
    NSURLSessionConfiguration *configure=[NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session=[NSURLSession sessionWithConfiguration:configure];
    NSURLSessionDataTask *dataTask=[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"done");
        completionHandler(UIBackgroundFetchResultNewData);
    }];
    [dataTask resume];
}

//nsurlsession download task
-(void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler
{
    NSLog(@"Application delegate: Background download task finished");
    self.backgroundURLSessionCompletionHandler=completionHandler;
}

#pragma mark - avaudioplayer delegate

-(void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
{
    NSLog(@"audio player begin interruption");
}

-(void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    NSLog(@"audio player decode error");
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSLog(@"audio player did finish playing");
}

@end
