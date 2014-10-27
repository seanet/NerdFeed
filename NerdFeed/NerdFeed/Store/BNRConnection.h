//
//  BNRConnection.h
//  NerdFeed
//
//  Created by zhaoqihao on 14-9-1.
//  Copyright (c) 2014年 com.zhaoqihao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONSerializable.h"
#import "UpdateProgressDelegate.h"

@interface BNRConnection : NSObject<NSURLSessionDelegate,NSURLSessionDownloadDelegate,NSURLSessionTaskDelegate,NSURLSessionDataDelegate>
{
    NSURLSession *currentSession;
    NSURLSessionTask *downloadTask;
        
    NSData *container;
}

@property (nonatomic,assign)id<UpdateProgressDelegate>delegate;

@property (nonatomic,copy)NSURLRequest *request;
@property (nonatomic,copy)void(^completionBlock)(id obj,NSError *err);

@property (nonatomic,strong)id<NSXMLParserDelegate>xmlRootObject;
@property (nonatomic,strong)id<JSONSerializableDelegate>jsonRootObject;

@property (nonatomic,strong)NSString *backgroundSessionID;

-(id)initWithRequest:(NSURLRequest *)req;

-(void)start;

@end
