//
//  BNRConnection.m
//  NerdFeed
//
//  Created by zhaoqihao on 14-9-1.
//  Copyright (c) 2014年 com.zhaoqihao. All rights reserved.
//

#import "BNRConnection.h"
#import "NerdFeedAppDelegate.h"

static NSMutableArray *sharedConnectionList=nil;

@implementation BNRConnection
@synthesize request=_request,completionBlock=_completionBlock;
@synthesize xmlRootObject=_xmlRootObject,jsonRootObject=_jsonRootObject;
@synthesize backgroundSessionID=_backgroundSessionID;

-(id)initWithRequest:(NSURLRequest *)req
{
    self=[super init];
    if(self){
        [self setRequest:req];
    }
    
    return self;
}

-(void)dealloc
{
    self.delegate=nil;
}

-(NSURLSession *)backgroundSession
{
    NSURLSessionConfiguration *configure=[NSURLSessionConfiguration backgroundSessionConfiguration:self.backgroundSessionID];
    NSURLSession *backgroundSession=[NSURLSession sessionWithConfiguration:configure delegate:self delegateQueue:nil];
    
    return backgroundSession;
}

-(NSURLSession *)defaultSession
{
    NSURLSessionConfiguration *configure=[NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession=[NSURLSession sessionWithConfiguration:configure delegate:self delegateQueue:nil];
    
    return defaultSession;
}

-(void)start
{
    if(!currentSession){
        currentSession=[self backgroundSession];
//        currentSession =[self defaultSession];
    }
    
    if(!sharedConnectionList){
        sharedConnectionList=[[NSMutableArray alloc]init];
    }
    [sharedConnectionList addObject:self];
    
    downloadTask=[currentSession downloadTaskWithRequest:self.request];
//    downloadTask=[currentSession dataTaskWithRequest:self.request];
    [downloadTask resume];
    NSLog(@"---------- start ----------");
}

#pragma mark - nsurlsession task delegate

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    NSLog(@"URLSession: did complete with error");
    
    if(error){
        NSLog(@"download failed: %@",[error description]);
        dispatch_async(dispatch_get_main_queue(), ^{
            self.completionBlock(nil,error);
        });
        [sharedConnectionList removeObject:self];
        
        return;
    }
    
    id rootObject=nil;
    
    if(self.xmlRootObject){
        NSXMLParser *parser=[[NSXMLParser alloc]initWithData:container];
        [parser setDelegate:self.xmlRootObject];
        [parser parse];
        
        rootObject=self.xmlRootObject;
    }else if(self.jsonRootObject){
        NSDictionary *dict=[NSJSONSerialization JSONObjectWithData:container options:NSJSONReadingMutableContainers error:nil];
        [self.jsonRootObject readFromJSONDictionary:dict];
        
        rootObject=self.jsonRootObject;
    }
    
    if(self.completionBlock){
        dispatch_async(dispatch_get_main_queue(), ^{
            self.completionBlock(rootObject,nil);
        });
    }
    
    [sharedConnectionList removeObject:self];
    [currentSession finishTasksAndInvalidate];
}

#pragma mark - nsurlsession downloadTask delegate

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    if(session==currentSession){
        NSLog(@"URLSession: did finish download");
        
        container=[NSData dataWithContentsOfFile:[location path]];
    }
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    if(totalBytesExpectedToWrite!=NSURLSessionTransferSizeUnknown){
        double progress=totalBytesWritten/(double)totalBytesExpectedToWrite;
        [self.delegate updateProgress:progress];
    }
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
    //
}

#pragma mark - nsurlsession data task delegate

-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    NSLog(@"receive response");
}

-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    NSLog(@"receive data");
}

#pragma mark - nsurlsession delegate

-(void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
    NSLog(@"did finish events for background session");
    
    if(session==currentSession){
        NerdFeedAppDelegate *appDelegate=(NerdFeedAppDelegate *)[[UIApplication sharedApplication]delegate];
        if([appDelegate backgroundURLSessionCompletionHandler]){
            void(^handler)()=[appDelegate backgroundURLSessionCompletionHandler];
            [appDelegate setBackgroundURLSessionCompletionHandler:nil];
            handler();
        }
    }
}

-(void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error
{
    NSLog(@"session become invalid");
    
    if(session ==currentSession){
        currentSession=nil;
        downloadTask=nil;
        container=nil;
    }
}

@end
